# Unscanny

Painless string scanning.

rewrite [Unscanny](https://github.com/typst/unscanny) in moonbit

```
[dependencies]
unscanny = "0.1.0"
```

Basically, you'll want to use this package if it's too much pain to solve your problem with a bare iterator. Speaking more broadly, unscanny is useful in these situations:

- You need to parse simple flat grammars (dates, times, custom stuff, ...) and want an interface that's a bit more convenient to use than a simple char iterator.
- You're hand-writing a tokenizer.

The Scanner keeps an internal cursor, allows you to peek around it, advance it beyond chars or other patterns and easily slice substrings before and after the cursor.

# Example

Recognizing and parsing a simple comma separated list of floats.

```moonbit
let s = Scanner::new(" +12 , -15.3, 14.3  ")
let nums = []
while not(s.done()) {
    let _ = s.eat_whitespace()
    let start = s.cursor()
    let _ = s.eat_if(['+', '-'])
    let _ = s.eat_while(CharPredicate::new(Char::is_ascii_digit))
    let _ = s.eat_if('.')
    let _ = s.eat_while(CharPredicate::new(Char::is_ascii_digit))
    nums.push(@strconv.parse_double(s.from(start)));
    let _ = s.eat_whitespace();
    let _ = s.eat_if(',');
}
assert_eq(nums, [12.0, -15.3, 14.3])
```
