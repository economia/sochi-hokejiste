ig.utils = utils = {}

utils.draw-bg = (baseElement, padding = {}) ->
    bgElement = document.createElement \div
        ..className    = "ig-background"
    ihned = document.querySelector '#ihned'
    if ihned
        that.parentNode.insertBefore bgElement, ihned
    reposition = -> reposition-bg baseElement, bgElement, padding
    reposition!
    setInterval reposition, 1000


reposition-bg = (baseElement, bgElement, padding) ->
    {top} = utils.offset baseElement
    height = baseElement.offsetHeight
    if padding.top
        top += that
        height -= that
    if padding.bottom
        height += that
    bgElement
        ..style.top    = "#{top}px"
        ..style.height = "#{height}px"


utils.offset = (element, side) ->
    top = 0
    left = 0
    do
        top += element.offsetTop
        left += element.offsetLeft
    while element = element.offsetParent
    {top, left}
