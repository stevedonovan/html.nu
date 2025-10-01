# A Nu DSL for constructing HTML (and XML) docuemnts

def is-type [ls tp] {
    ($ls | describe -d | get type) == $tp
}

def is-xml [el] {
    (is-type $el 'record') and ($el | columns) == [tag attributes content]
}

def as-text [] {
    if (is-xml $in) {
        $in
    } else {
        $in | to text
    }
}

# Create an XML/HTML element
#
# If the first of the container arguments is a list, then this is used,
# otherwise the rest of the arguments are passed. A non-list argument
# is wrapped in a list
export def tag [
    --class (-c): string # specify class attribute directly
    --id (-i): string # specify id attribute directly
    --attr (-a): record # any other attributes
    tag: string  # the tag
    ...rest # the contained elements
] {
    mut attr = $attr | default {}
    if ($id | is-not-empty) {
        $attr.id = $id
    }
    if ($class | is-not-empty) {
        $attr.class = $class
    }
    let $contents = if ($rest | length) == 1 and (is-type $rest.0 'list') {
        $rest.0
    } else {
        $rest
    }

    {
        tag: $tag
        attributes: $attr
        content: $contents
    }
}

# convert a Nu table into an HTML table
#
# unlike `to html` this does not wrap as a top-level HTML document
# and gnerates data in XML format, not text
export def html-table [
        tab: table # the table 
    ] {
    let tab = $in | default $tab
    tag table [
        (tag thead [(tag tr ($tab | columns | each {|v| tag th $v}))])
        (tag tbody ($tab 
            | each { values } # list of rows            
            | each {|r| # wrap row values in td
               tag tr ($r | each {|v| tag td [($v | as-text)]})
            }
        ))
    ]
}

# convert a NU list into an HTML list
#
# Values which are *not* themselves XML are converted to text
@example "Wrap a simple list as an unordered HTML list" { 
    list ul li [one two three] | render
} --result '#
# <ul>
#   <li>one</li>
#   <li>two</li>
#   <li>three</li>
# </ul>
'
export def list [
    otag: string # the outer tag, e.g ul
    itag: string # the inner tag, usually li
    ls: list # the list
] {
    tag $otag ($ls | each {|v| tag $itag ($v | as-text)})
}

# a convenient helper to make a <a> link
#
# if the arguments are not provided, then receives a list
# containing the caption and the link
@example "rendering data as a list of links" {
    list ul li (
        [
            ['Home' '/index.html']
            ['Help' '/manual.html']
        ] | each { link }
    )
} --result '#
# <ul>
#   <li>
#     <a href="/index.html">Home</a>
#   </li>
#   <li>
#     <a href="/manual.html">Help</a>
#   </li>
# </ul>
'
export def link [
    caption?: string
    link?: string
] {
    let input = if ($link | is-not-empty ) {
        [$caption $link]
    } else {
        $in
    }
    tag a -a {href: $input.1} $input.0
}

# render the data as HTML/XML text
export def render [] {
    to xml -i 2 -s
}

export alias form = tag form
export alias fieldset = tag fieldset
export alias input = tag input
export alias meta = tag meta
export alias title = tag tile
export alias h1 = tag h1
export alias a = tag a
export alias p = tag p
export alias span = tag span
export alias div = tag div

