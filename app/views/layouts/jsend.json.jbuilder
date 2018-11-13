json.status :success
json.data do
  json.merge! JSON.parse(yield)
end