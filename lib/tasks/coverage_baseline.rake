# TTPLAT-3072 P8 — gate on covered lines (never percentage; see §0 of the
# P8 brief and the comments at the top of spec/coverage_baseline.yml).
# TTPLAT-3072 P8a — everything this file defines lives inside
# TransamCoreCoverageBaseline, not at file/Object scope. `namespace do...end`
# is an ordinary block, not a lexical scope for constants or `def`, so the
# P8 version of this file assigned ::MANIFEST_PATH and a top-level method on
# Object -- the same names transam_transit's identical-shaped file also
# assigns. Once transit's dummy app loads this engine, the two collide.
# See §0/§1 of the P8a brief.
# TTPLAT-3072 P8b — closes a hole in P8a's §2b guard: `dig(...).to_i.zero?`
# reads a file with NO per_file record (or a per_file entry with no `covered`
# key) as "pinned synthetic," so it could go dark in a real run and never
# trip newly_synthetic. Fixed two ways in check_coverage_baseline only (never
# pin_coverage_baseline, which repairs an inconsistent manifest and must keep
# running against one): §1a below rejects a manifest whose groups/per_file
# disagree in either direction, or whose covered value isn't an Integer,
# before the resultset is even opened; §1b makes pinned_synthetic check
# `is_a?(Integer) && zero?` instead of `to_i.zero?` as defense in depth.
require 'yaml'
require 'json'
require 'date'

module TransamCoreCoverageBaseline
  MANIFEST_PATH = File.expand_path('../../../spec/coverage_baseline.yml', __FILE__)

  def self.load_rspec_coverage(root)
    resultset_path = File.join(root, 'coverage', '.resultset.json')
    abort "COVERAGE BASELINE: no coverage data; run the suite first." unless File.exist?(resultset_path)
    data = JSON.parse(File.read(resultset_path))
    unless data.key?('RSpec')
      abort "COVERAGE BASELINE: no RSpec key in coverage/.resultset.json (found: #{data.keys.inspect}); run the suite first."
    end
    data['RSpec']
  end
end

namespace :transam_core do
  desc "Gate on the covered-line floor pinned in spec/coverage_baseline.yml"
  task :check_coverage_baseline do
    root = File.expand_path('../../..', __FILE__)
    manifest = YAML.load_file(TransamCoreCoverageBaseline::MANIFEST_PATH)

    # TTPLAT-3072 P8b §1a — manifest self-consistency check, before the
    # resultset is even opened: a defect in the manifest is reported
    # identically whether or not a suite has run. check_coverage_baseline
    # ONLY -- pin_coverage_baseline rebuilds informational.per_file from
    # groups wholesale and is the tool that repairs an inconsistent
    # manifest, so it must keep running against one.
    group_files = manifest['groups'].values.flatten
    per_file = manifest.dig('informational', 'per_file') || {}
    missing_per_file = group_files - per_file.keys
    stale_per_file = per_file.keys - group_files
    non_integer_covered = per_file.select { |_rel, v| !v.is_a?(Hash) || !v['covered'].is_a?(Integer) }.keys
    if !missing_per_file.empty? || !stale_per_file.empty? || !non_integer_covered.empty?
      msg = ["COVERAGE BASELINE: manifest is not self-consistent (groups has #{group_files.size} files, " \
             "informational.per_file has #{per_file.size} files)."]
      msg << "In groups but missing an informational.per_file entry: #{missing_per_file.join(', ')}" unless missing_per_file.empty?
      msg << "In informational.per_file but not listed in any group: #{stale_per_file.join(', ')}" unless stale_per_file.empty?
      msg << "informational.per_file entries whose covered value is not an Integer: #{non_integer_covered.join(', ')}" unless non_integer_covered.empty?
      msg << "Remedy: run pin_coverage_baseline after a full suite run to rebuild informational.per_file from groups."
      abort msg.join("\n")
    end

    rspec = TransamCoreCoverageBaseline.load_rspec_coverage(root)

    age = Time.now - Time.at(rspec['timestamp'])
    if age > 1800
      abort "COVERAGE BASELINE: coverage data is stale (#{age.round}s old, from #{Time.at(rspec['timestamp'])}); run the suite again before checking."
    end
    coverage = rspec['coverage']

    total_covered = 0
    total_relevant = 0
    failing_files = []
    group_rows = []
    current_synthetic = []

    manifest['groups'].each do |group_name, files|
      g_covered = 0
      g_relevant = 0
      files.each do |rel|
        abs = File.expand_path(File.join(root, rel))
        entry = coverage[abs]
        if entry.nil?
          abort "COVERAGE BASELINE: manifest file #{rel} is missing from the resultset entirely (not merely " \
                "uncovered) -- it was likely deleted or renamed. Update spec/coverage_baseline.yml's groups."
        end
        lines = entry.is_a?(Hash) ? entry['lines'] : entry
        covered = lines.count { |x| x && x > 0 }
        relevant = lines.count { |x| !x.nil? }
        g_covered += covered
        g_relevant += relevant
        current_synthetic << rel if covered.zero?
        recorded = manifest.dig('informational', 'per_file', rel, 'covered')
        failing_files << [rel, covered, recorded] if recorded && covered < recorded
      end
      group_rows << [group_name, g_covered, g_relevant]
      total_covered += g_covered
      total_relevant += g_relevant
    end

    floor = manifest['floor']['covered']
    info = manifest['informational'] || {}
    percent = total_relevant.zero? ? 0.0 : (total_covered * 100.0 / total_relevant)

    # TTPLAT-3072 P8a §2b — exact partial-run guard. A file with covered==0 is
    # a file the run never loaded (P7: zero exceptions across 262 files). The
    # PINNED synthetic set is every per_file entry already recorded at
    # covered: 0; the CURRENT synthetic set is computed the same way above.
    # newly_synthetic (pinned non-zero, now zero) means files dropped out --
    # on a genuine partial run that's most of the manifest at once, so more
    # than roughly a quarter of the manifest going synthetic in one run reads
    # as a partial run rather than a couple of files losing coverage. This
    # check is NOT redundant with the covered-lines floor above: a single
    # file quietly losing all its coverage in an otherwise-full run still
    # pulls total_covered below the floor and is caught there instead --
    # the two checks are complementary. no_longer_synthetic (pinned zero, now
    # covered) is the good direction (first-time coverage) and is only
    # informational; re-pinning via pin_coverage_baseline clears the note.
    pinned_synthetic = manifest['groups'].values.flatten.select do |rel|
      recorded = manifest.dig('informational', 'per_file', rel, 'covered')
      recorded.is_a?(Integer) && recorded.zero?
    end
    newly_synthetic = current_synthetic - pinned_synthetic
    no_longer_synthetic = pinned_synthetic - current_synthetic

    puts "== transam_core coverage baseline (#{TransamCoreCoverageBaseline::MANIFEST_PATH}) =="
    puts "%-20s %8s %8s %8s" % ["group", "covered", "relevant", "percent"]
    group_rows.each { |name, c, r| puts "%-20s %8d %8d %7.2f%%" % [name, c, r, r.zero? ? 0.0 : c * 100.0 / r] }
    puts "-" * 50
    puts "%-20s %8d %8d %7.2f%%  (floor %d, delta %+d; informational relevant %d, delta %+d)" %
      [ "TOTAL", total_covered, total_relevant, percent, floor, total_covered - floor,
        info['relevant'].to_i, total_relevant - info['relevant'].to_i ]

    if !newly_synthetic.empty?
      manifest_file_count = manifest['groups'].values.flatten.size
      kind = newly_synthetic.size > (manifest_file_count / 4.0) ? "a partial run" : "a small number of files no longer being exercised"
      puts "\nFiles synthetic now that were NOT synthetic when pinned (reads as #{kind}):"
      newly_synthetic.each { |rel| puts "  #{rel}" }
      abort "\nCOVERAGE BASELINE FAILED: #{newly_synthetic.size} of #{manifest_file_count} manifest files went to " \
            "covered=0 that were not synthetic when pinned -- #{kind}. Re-run the full suite (after clearing " \
            "coverage/.resultset.json and coverage/.last_run.json) before checking again."
    end

    if !no_longer_synthetic.empty?
      puts "\nNote: files synthetic when pinned that are now exercised for the first time (informational only, not a failure):"
      no_longer_synthetic.each { |rel| puts "  #{rel}" }
      puts "Re-pinning (pin_coverage_baseline) will clear this note."
    end

    if total_covered < floor
      shortfall = floor - total_covered
      puts "\nPer-file rows below recorded covered count:"
      failing_files.each { |rel, c, rec| puts "  %-55s covered=%d recorded=%d (down %d)" % [rel, c, rec, rec - c] }
      abort "\nCOVERAGE BASELINE FAILED: actual covered=#{total_covered}, recorded floor=#{floor}, shortfall=#{shortfall}."
    end
    puts "\nCOVERAGE BASELINE PASSED: actual covered=#{total_covered} >= floor=#{floor}."
  end

  desc "Rewrite spec/coverage_baseline.yml's floor/informational numbers from the current resultset"
  task :pin_coverage_baseline do
    root = File.expand_path('../../..', __FILE__)
    manifest = YAML.load_file(TransamCoreCoverageBaseline::MANIFEST_PATH)
    rspec = TransamCoreCoverageBaseline.load_rspec_coverage(root)
    coverage = rspec['coverage']

    total_covered = 0
    total_relevant = 0
    per_file = {}
    manifest['groups'].each_value do |files|
      files.each do |rel|
        entry = coverage[File.expand_path(File.join(root, rel))]
        abort "PIN COVERAGE BASELINE: #{rel} missing from resultset -- can't pin." if entry.nil?
        lines = entry.is_a?(Hash) ? entry['lines'] : entry
        c = lines.count { |x| x && x > 0 }
        r = lines.count { |x| !x.nil? }
        per_file[rel] = { 'covered' => c, 'relevant' => r }
        total_covered += c
        total_relevant += r
      end
    end

    manifest['pinned_at'] = Date.today.to_s
    manifest['pinned_from'] = "pin_coverage_baseline, #{Time.now}"
    manifest['floor'] = { 'covered' => total_covered }
    manifest['informational'] ||= {}
    manifest['informational']['relevant'] = total_relevant
    manifest['informational']['percent'] = (total_covered * 100.0 / total_relevant).round(2)
    manifest['informational']['per_file'] = per_file

    # Preserve the leading `#` comment block (false-failure-mode notes, §7)
    # from the file on disk -- YAML.dump has no comment syntax, so a plain
    # `manifest.to_yaml` would silently delete them on every re-pin.
    header = File.readlines(TransamCoreCoverageBaseline::MANIFEST_PATH).take_while { |l| l.start_with?('#') }.join
    File.write(TransamCoreCoverageBaseline::MANIFEST_PATH, header + manifest.to_yaml)
    puts "Re-pinned #{TransamCoreCoverageBaseline::MANIFEST_PATH}: covered=#{total_covered} relevant=#{total_relevant}"
  end
end
