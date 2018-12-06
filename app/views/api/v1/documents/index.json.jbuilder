json.documents do 
  json.partial! 'api/v1/documents/document', collection: @documents, as: :document
end