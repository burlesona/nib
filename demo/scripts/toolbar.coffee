# Sample Toolbar

# This UI code is not part of the editor, but merely a demonstration of how
# to create a UI that can call an editor instance.

sendCommand = (event) ->
  event.preventDefault()
  ed.exec event.target.dataset.command
  false

buttons = document.getElementById('toolbar').childNodes
button.addEventListener('click', sendCommand) for button in buttons
