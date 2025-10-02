# Helpers for expanding Nu data representations

# Create a new record by mapping over the values
#
# The new record has the same keys, with `_KEY`
# giving the key
export def MAP [
    m: record 
    cc: closure
] {
    if $m == null {
        return
    }
    $m | items {|k v|
      let mv = do $cc ($v | recordify | upsert _KEY $k)
      [$k $mv]
    } | into record
}

# Create a new list from the input, like `each`
#
# The difference that if the second argument is a string,
# then it is assumed to be for `format pattern`. In which
# case if the values aren't records we make up a fake
# record with the key `_`
export def LIST [
    l: list
    cc: any # either a closure or a string pattern
] {
    if $l == null {
        return
    }
    let cc = if ($cc | tp ) == "string" {
        { recordify | format pattern $cc }
    } else {
        $cc
    }
    $l | each $cc
}

# Only create entries if the record values are non-null
export def NON-NULL [
    rec: record
] {
    $rec | items {|k v| 
       if $v != null {  
         [$k $v] 
       }
    } | into record
}

# scan over the IR of a closure and make a list of commands called
export def ir-scan [calls close] {
    # print $'we got ($close) ($close | describe)'

    let ir = view ir $close
    $ir | lines | each {|l| 
        let try_call = $l | parse -r '\d+: call\s+decl \d+ "(?<name>[^"]+)"' | get 0?
        if $try_call != null {
            $try_call.name
        } else {
            let try_close = $l | parse -r '\d+: load\-literal\s+%\d+, closure\((?<close>[^)]+)' | get 0?
            if $try_close != null {
                # print $try_close
                ir-scan $calls ($try_close.close | into int)
            }
        }
    } | flatten
}

def tp [] {
    describe -d | get type
}

def recordify [] {
    let inp = $in
    if ($inp | tp) == "record" {
        $inp        
    } else {
        {_: $inp}
    }
}

