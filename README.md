# html.nu
A DSL for generating HTML (and XML) in Nushell

## HTML

This consists of a few commmands and aliases; this makes it easier to
express HTML in Nushell. Building HTML in code gives us power to modularize 
generation. Say all our documents use [PicoCSS](https://picocss.com), then it's easy 
to write the 'envelope' once and then actual documents can be made built on this;

```nushell
use /path/to/html.nu *

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
) | render
```
## Expanding arbitrary Data

```nushell
use /path/to/expand.nu *

{
  services: (MAP $data.data {|v| NON-NULL { 
      image: $"ourtech/($v._KEY):($v.version)"
      ports: (LIST $v.ports "{_}:{_}")
      volumes: $v.volumes?
    } 
  })
} | to yaml
```

`MAP` operates on the values of a record (tho inserts the key as `_KEY`); `LIST` operates on a list, much like `each` except with a special where a `format pattern` can be used.

`NON-NULL` is interesting - it is like a record literal that does not insert `null` values.

So if `data` is:

```yaml
data:
  dog:
    version: 1.2
    ports: [2555]
  cat:
    version: 0.8
    ports: [1023]
    volumes: [/:/hostfs.ro]

```

then the result is 

```yaml
data:
  dog:
    version: 1.2
    ports: [2555]
  cat:
    version: 0.8
    ports: [1023]
    volumes: [/:/hostfs.ro]
```
