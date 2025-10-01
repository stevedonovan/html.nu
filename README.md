# html.nu
A DSL for generating HTML (and XML) in Nushell

```nu
use /path/to/html.nu *
```
This consists of a few commmands and aliases; this makes it easier to
express HTML in Nushell. Building HTML in code gives us power to modularize 
generation. Say all our documents use [PicoCSS](https://picocss.com), then it's easy 
to write the 'envelope' once and then actual documents can be made built on this;

```nu
def pico-main [...rest] {
    (tag html
        (tag head -a {lang: 'en'} 
            (meta -a {name: "viewport" content: "width=device-width, initial-scale=1"})
            (meta -a {name: "color-schema" content: "light dark"})
            (tag link -a {rel: 'stylesheet' href: "pico-main/css/pico.min.css"})
            (title 'Hello World')
        )
        (tag body
            (tag main -c 'container'
               $rest
            )    
        )
    )
}

(pico-main
    (h1 'Hello World')
    (list ul li (
        [
            ['Home' '/index.html']
            ['Help' '/manual.html']
        ] | each { link }
    ))
    (html-table (ls))
)
```



