require 'rails_helper'

RSpec.describe ReplaceableAsset do

  # Cataloged as M4 in the TTPLAT-3072 mirror list (implying a legacy parity
  # obligation), but no legacy spec anywhere in the repo exercises disposable?,
  # eligible_for_early_disposition_request?, or scheduled_for_disposition? by
  # name - a repo-wide grep confirms this. Treating these as coverage-screen
  # gains (no legacy counterpart) rather than fabricating a citation.
  #
  # All eight scenarios below were built and their real return values observed
  # and reported before writing any assertion (mirror report 3), then ruled
  # against the source (mirror brief §3c) before being written as expectations.
  describe 'disposable?, eligible_for_early_disposition_request?, and scheduled_for_disposition?' do
    it 'scenario A: future replacement year, no early disposition requests' do
      test_asset = create(:buslike_asset, :policy_replacement_year => Date.today.year + 5)

      expect(test_asset.disposed?).to be false
      # disposable? returns nil here (early_disposition_requests.last is nil,
      # and nil.try(:is_unconditional_approved?) is nil), not false. Ruled:
      # the method should arguably return false, but is unlikely to be
      # compared to it directly; normalizing this to false is a deliberate
      # open possibility, not something this mirror should paper over by
      # asserting be_falsey against a return value someone may one day fix.
      expect(test_asset.disposable?).to be_falsey
      expect(test_asset.disposable?(true)).to be_falsey
      expect(test_asset.eligible_for_early_disposition_request?).to be true
      expect(test_asset.scheduled_for_disposition?).to be false
    end

    it 'scenario B: past replacement year, no early disposition requests' do
      test_asset = create(:buslike_asset, :policy_replacement_year => Date.today.year - 5)

      expect(test_asset.disposed?).to be false
      expect(test_asset.disposable?).to be true
      expect(test_asset.disposable?(true)).to be true
      expect(test_asset.eligible_for_early_disposition_request?).to be false
      expect(test_asset.scheduled_for_disposition?).to be false
    end

    it 'scenario C: future replacement year, an unconditionally approved early disposition request' do
      test_asset = create(:buslike_asset, :policy_replacement_year => Date.today.year + 5)
      request = test_asset.early_disposition_requests.create!(attributes_for(:early_disposition_request_update_event))
      request.update_column(:state, 'approved')

      expect(test_asset.disposed?).to be false
      expect(test_asset.disposable?).to be true
      expect(test_asset.disposable?(true)).to be true
      expect(test_asset.eligible_for_early_disposition_request?).to be false
      expect(test_asset.scheduled_for_disposition?).to be false
    end

    it 'scenario D: future replacement year, a rejected early disposition request' do
      test_asset = create(:buslike_asset, :policy_replacement_year => Date.today.year + 5)
      request = test_asset.early_disposition_requests.create!(attributes_for(:early_disposition_request_update_event))
      request.update_column(:state, 'rejected')

      expect(test_asset.disposed?).to be false
      expect(test_asset.disposable?).to be false
      expect(test_asset.disposable?(true)).to be false
      expect(test_asset.eligible_for_early_disposition_request?).to be true
      expect(test_asset.scheduled_for_disposition?).to be false
    end

    it 'scenario E: future replacement year, a transfer-approved early disposition request' do
      test_asset = create(:buslike_asset, :policy_replacement_year => Date.today.year + 5)
      request = test_asset.early_disposition_requests.create!(attributes_for(:early_disposition_request_update_event))
      request.update_column(:state, 'transfer_approved')

      expect(test_asset.disposed?).to be false
      # Ruled by design: disposable? without the parameter does not count a
      # transfer approval (is_unconditional_approved? checks state == 'approved'
      # only); passing true switches to is_approved?, which also accepts
      # 'transfer_approved'. This asymmetry is exactly why disposable? takes
      # the parameter.
      expect(test_asset.disposable?).to be false
      expect(test_asset.disposable?(true)).to be true
      expect(test_asset.eligible_for_early_disposition_request?).to be false
      expect(test_asset.scheduled_for_disposition?).to be false
    end

    it 'scenario F: scheduled for disposition, past replacement year' do
      # scheduled_for_disposition? is scheduled_disposition_year.present? and
      # disposed? == false - entirely orthogonal to the ESL boundary, so a
      # past replacement year and a scheduled disposition both reading true
      # together is expected, not an interaction to special-case (ruled,
      # mirror brief §3c). policy_replacement_year is left at the factory
      # default (2000, already past) rather than set explicitly, since this
      # scenario is about scheduled_disposition_year.
      test_asset = create(:buslike_asset, :scheduled_disposition_year => Date.today.year + 1)

      expect(test_asset.disposed?).to be false
      expect(test_asset.disposable?).to be true
      expect(test_asset.disposable?(true)).to be true
      expect(test_asset.eligible_for_early_disposition_request?).to be false
      expect(test_asset.scheduled_for_disposition?).to be true
    end

    it 'scenario G: a disposed asset' do
      test_asset = create(:buslike_asset, :policy_replacement_year => Date.today.year + 5, :scheduled_disposition_year => Date.today.year + 1)
      test_asset.update_column(:disposition_date, Date.today)

      expect(test_asset.disposed?).to be true
      expect(test_asset.disposable?).to be false
      expect(test_asset.disposable?(true)).to be false
      expect(test_asset.eligible_for_early_disposition_request?).to be false
      expect(test_asset.scheduled_for_disposition?).to be false
    end

    it 'scenario H: policy_replacement_year is blank' do
      test_asset = create(:buslike_asset)
      test_asset.update_column(:policy_replacement_year, nil)

      expect(test_asset.disposed?).to be false
      expect(test_asset.disposable?).to be false
      expect(test_asset.disposable?(true)).to be false
      expect(test_asset.eligible_for_early_disposition_request?).to be false
      expect(test_asset.scheduled_for_disposition?).to be false
    end
  end
end
