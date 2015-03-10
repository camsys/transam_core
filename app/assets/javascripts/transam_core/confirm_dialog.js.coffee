# Override Rails handling of confirmation

$.rails.allowAction = (element) ->
  # The message is something like "Are you sure?"
  message = element.data('confirm')
  # If there's no message, there's no data-confirm attribute,
  # which means there's nothing to confirm
  return true unless message
  # Clone the clicked element (probably a delete link) so we can use it in the dialog box.
  $link = element.clone()
    # We don't necessarily want the same styling as the original link/button.
    .removeAttr('class')
    .removeAttr('style')
    # We don't want to pop up another confirmation (recursion)
    .removeAttr('data-confirm')
    # We want a button
    .addClass('btn').addClass('btn-success')
    # We want it to sound confirmy
    .html("Yes")

  # Create the modal box with the message
  modal_html = """
               <div class="modal" id="confirm_dialog_modal">
                 <div class="modal-dialog">
                   <div class='modal-content'>
                     <div class='modal-body'>
                        <p>#{message}</p>
                     </div>
                    <div class="modal-footer">
                      <a data-dismiss="modal" class="btn btn-default">Cancel</a>
                    </div>
                  </div>
               </div>
             </div>
               """
  $modal_html = $(modal_html)
  # Add the new button to the modal box
  $modal_html.find('.modal-footer').append($link)
  attach = element.data('attach')
  attach = $(attach)
  # If they didn't specify where to attach, this just attaches at bottom of doc
  attach.after($modal_html)
  # Pop it up
  $modal_html.modal()
  # Prevent the original link from working
  return false
