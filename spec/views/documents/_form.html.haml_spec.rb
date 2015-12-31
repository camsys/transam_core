require 'rails_helper'

describe "documents/_form.html.haml", :type => :view do
  it 'fields' do
    assign(:documentable, create(:buslike_asset))
    render

    expect(rendered).to have_field('document_document')
    expect(rendered).to have_field('document_description')
  end
end
