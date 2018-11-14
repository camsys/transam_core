status = @status || :success
json.ignore_nil!
json.status status
if status == :success
  json.data do
    json.merge! JSON.parse(yield)
  end
elsif status == :error || status == :fail
  json.message @message 
  if @data
    json.data do
      json.merge! @data
    end
  end
  json.code = @code
end