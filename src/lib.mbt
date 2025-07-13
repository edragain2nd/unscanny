///|
pub struct Scanner {
  /// The string to scan.
  str : String
  /// The index at which we currently are. To guarantee safety, it must always
  /// hold that:
  /// - 0 <= cursor <= string.len()
  /// - cursor is on a character boundary

  /// moonbit's String.length() returns Int
  mut cursor : Int
}

///|
/// Creates a new scanner for parsing the given string.
///
/// Parameters:
///
/// * `str` : The string to be scanned and parsed.
///
/// Returns a new `Scanner` instance positioned at the beginning of the string
/// with the cursor at position 0.
///
/// Example:
///
/// ```moonbit
/// let scanner = Scanner::new("hello world")
/// inspect(scanner.cursor(), content="0")
/// inspect(scanner.string(), content="hello world")
/// ```
///
pub fn Scanner::new(str : String) -> Scanner {
  { str, cursor: 0 }
}

///|
/// Returns the string being scanned by this scanner.
///
/// Parameters:
///
/// * `self` : The scanner instance.
///
/// Returns the original string that was provided when the scanner was created.
///
/// Example:
///
/// ```moonbit
/// let scanner = Scanner::new("hello world")
/// inspect(scanner.string(), content="hello world")
/// ```
///
pub fn Scanner::string(self : Scanner) -> String {
  self.str
}

///|
/// Returns the cursor of this scanner.
///
/// Parameters:
///
/// * `self` : The scanner instance.
///
/// Returns the cursor
///
/// Example:
///
/// ```moonbit
/// let scanner = Scanner::new("hello world")
/// inspect(scanner.cursor(), content="0")
/// ```
///
pub fn Scanner::cursor(self : Scanner) -> Int {
  self.cursor
}

///|
/// Check if cursor reach end of the string
///
/// Parameters:
///
/// * `self` : The scanner instance.
///
/// Returns the Bool
///
/// Example:
///
/// ```moonbit
/// let scanner = Scanner::new("hello world")
/// inspect(scanner.done(), content="false")
/// ```
///
pub fn Scanner::done(self : Scanner) -> Bool {
  self.cursor == self.str.length()
}

///|
/// Returns the portion of the string that comes before the current cursor
/// position.
/// Parameters:
///
/// * `self` : The scanner instance.
/// 
/// Returns a string containing all characters from the beginning of the scanned
/// string up to (but not including) the current cursor position.
///
pub fn Scanner::before(self : Scanner) -> String {
  self.str.substring(start=0, end=self.cursor)
}

///|
/// Returns the portion of the string that comes after the current cursor
/// position.
/// Parameters:
///
/// * `self` : The scanner instance.
/// 
/// Returns a string containing all characters from the current cursor position
/// to the end of the scanned string.
///
pub fn Scanner::after(self : Scanner) -> String {
  self.str.substring(start=self.cursor, end=self.str.length())
}

///|
/// Returns a tuple containing the portions of the string before and after the
/// current cursor position.
///
/// Parameters:
///
/// * `self` : The scanner instance.
/// 
/// Returns a tuple where the first element is the string before the cursor and
/// the second element is the string after the cursor.
///
pub fn Scanner::parts(self : Scanner) -> (String, String) {
  (self.before(), self.after())
}

///|
/// Returns the substring from the given start position to the current cursor
/// position.
///
/// Parameters:
///
/// * `start` : The starting index for the substring extraction.
///
/// Returns a string containing characters from the start position (or current
/// cursor if it's smaller) to the current cursor position.
///
pub fn Scanner::from(self : Scanner, start : Int) -> String {
  let real_start = if self.cursor < self.snap(start) {
    self.cursor
  } else {
    self.snap(start)
  }
  self.str.substring(start=real_start, end=self.cursor)
}

///|
/// Returns the substring from the current cursor position to the specified end
/// position.
///
/// Parameters:
///
/// * `self` : The scanner instance.
/// * `end` : The target end position in the string. If this position is before
///   the current cursor, the cursor position is used as the end instead.
///
/// Returns a string containing characters from the current cursor position to
/// the effective end position.
pub fn Scanner::to(self : Scanner, end : Int) -> String {
  let real_end = if self.cursor > self.snap(end) {
    self.cursor
  } else {
    self.snap(end)
  }
  self.str.substring(start=self.cursor, end=real_end)
}

/// cos moonbit donot have syntax of slice or Range
/// we use two parameters instead

///|
/// Extracts a substring from the scanner's string between the specified start
/// and end positions.
///
/// Parameters:
///
/// * `self` : The scanner instance.
/// * `start` : The starting index for the substring extraction.
/// * `end` : The ending index for the substring extraction (exclusive).
///
/// Returns a string containing characters from the start position to the end
/// position. If the end position is not greater than the start position after
/// snapping to character boundaries, returns an empty string.
///
/// Example:
///
/// ```moonbit
/// let scanner = Scanner::new("hello world")
/// inspect(scanner.get(0, 5), content="hello")
/// inspect(scanner.get(6, 11), content="world")
/// inspect(scanner.get(2, 4), content="ll")
/// inspect(scanner.get(5, 2), content="") // end <= start returns empty string
/// ```
pub fn Scanner::get(self : Scanner, start : Int, end : Int) -> String {
  let real_start = self.snap(start)
  let real_end = if self.snap(end) > real_start {
    self.snap(end)
  } else {
    real_start
  }
  self.str.substring(start=real_start, end=real_end)
}

///|
/// Returns the character at the current cursor position without advancing the
/// cursor.
///
/// Parameters:
///
/// * `self` : The scanner instance.
///
/// Returns `Some(char)` if there is a character at the current position, or
/// `None` if the scanner has reached the end of the string.
///
/// Example:
///
/// ```moonbit
/// let scanner = Scanner::new("hello")
/// inspect(scanner.peek(), content="Some('h')")
/// let _ = scanner.eat() // advance cursor
/// inspect(scanner.peek(), content="Some('e')")
/// ```
///
pub fn Scanner::peek(self : Scanner) -> Char? {
  if self.done() {
    None
  } else {
    Some(self.str.char_at(self.cursor))
  }
}

///|
/// Checks if the scanner's remaining string matches the specified pattern at
/// the current cursor position.
///
/// Parameters:
///
/// * `self` : The scanner instance.
/// * `pat` : The pattern to match against the remaining string. Can be a
///   character, string, character array, or character predicate.
///
/// Returns `true` if the pattern matches at the current position, `false`
/// otherwise.
pub fn[T : Pattern] Scanner::at(self : Scanner, pat : T) -> Bool {
  pat.matches(self.after()) is Some(_)
}

///|
/// Returns the character at a relative position from the current cursor
/// position.
///
/// Parameters:
///
/// * `self` : The scanner instance.
/// * `n` : The relative position from the current cursor. Positive values look
///   forward in the remaining string, negative values look backward in the
///   scanned string.
///
/// Returns `Some(char)` if a character exists at the specified relative
/// position, or `None` if the position is out of bounds.
pub fn Scanner::scout(self : Scanner, n : Int) -> Char? {
  if n >= 0 {
    self.after().iter().nth(n)
  } else {
    self.before().rev().iter().nth(-n - 1)
  }
}

///|
/// return the byte index of nth char
/// in moonit utf16 is 4 bytes and ascii is 2 bytes
pub fn Scanner::locate(self : Scanner, n : Int) -> Int {
  let mut len = 0
  let mut sum = 0
  if n >= 0 {
    let after = self.after()
    len = n
    for c in after.iter() {
      if len == 0 {
        break
      }
      len -= 1
      sum += c.to_string().to_bytes().length()
    }
    return self.before().to_bytes().length() + sum
  } else {
    let before = self.before().rev()
    len = -n
    for c in before.iter() {
      if len == 0 {
        break
      }
      len -= 1
      sum += c.to_string().to_bytes().length()
    }
    return self.before().to_bytes().length() - sum
  }
}

///|
/// Consumes and returns the character at the current cursor position, advancing
/// the cursor to the next character.
///
/// Parameters:
///
/// * `self` : The scanner instance.
///
/// Returns `Some(char)` if there is a character at the current position, or
/// `None` if the scanner has reached the end of the string.
///
/// Example:
///
/// ```moonbit
/// let scanner = Scanner::new("hello")
/// inspect(scanner.eat(), content="Some('h')")
/// inspect(scanner.eat(), content="Some('e')")
/// inspect(scanner.peek(), content="Some('l')") // cursor now at 'l'
/// ```
///
pub fn Scanner::eat(self : Scanner) -> Char? {
  let peeked = self.peek()
  match peeked {
    Some(c) => {
      self.cursor += c.to_string().length()
      Some(c)
    }
    None => None
  }
}

///|
/// Consumes and returns the character at the current cursor position, advancing
/// the cursor to the prev character.
///
/// Parameters:
///
/// * `self` : The scanner instance.
///
/// Returns `Some(char)` if there is a character at the current position, or
/// `None` if the scanner has reached the end of the string.
pub fn Scanner::uneat(self : Scanner) -> Char? {
  let unpeeked = self.before().rev().iter().nth(0)
  match unpeeked {
    Some(unpeeked) as token => {
      self.cursor -= unpeeked.to_string().length()
      token
    }
    None => None
  }
}

///|
/// Conditionally consumes a pattern from the scanner if it matches at the
/// current cursor position.
///
/// Parameters:
///
/// * `self` : The scanner instance.
/// * `pat` : The pattern to match against the string at the current cursor
///   position. Can be a character, string, character array, or character
///   predicate.
///
/// Returns `true` if the pattern was successfully matched and consumed, `false`
/// if the pattern did not match (cursor position remains unchanged).
pub fn[T : Pattern] Scanner::eat_if(self : Scanner, pat : T) -> Bool {
  let len = pat.matches(self.after())
  if len is Some(len) {
    self.cursor += len
    true
  } else {
    false
  }
}

///|
/// Continuously consumes characters from the scanner that match the specified
/// pattern, advancing the cursor until a non-matching character is encountered.
///
/// Parameters:
///
/// * `self` : The scanner instance.
/// * `pat` : The pattern to match against characters in the string. Can be a
///   character, string, character array, or character predicate.
///
/// Returns a string containing all the characters that were consumed and
/// matched the pattern. If no characters match the pattern or if the scanner is
/// at the end of the string, returns an empty string.
pub fn[T : Pattern] Scanner::eat_while(self : Scanner, pat : T) -> String {
  guard self.after() != "" else { "" }
  let start = self.cursor
  let mut len = pat.matches(self.after())
  while len is Some(_) {
    self.cursor += len.unwrap()
    len = pat.matches(self.after())
  }
  self.from(start)
}

///|
/// Continuously consumes characters from the scanner until a character or
/// pattern that matches the specified pattern is encountered, without consuming
/// the matching character itself.
///
/// Parameters:
///
/// * `self` : The scanner instance.
/// * `pat` : The pattern to search for as a stopping condition. Can be a
///   character, string, character array, or character predicate. The scanner
///   will stop consuming characters when this pattern matches at the current
///   position.
///
/// Returns a string containing all the characters that were consumed before
/// encountering the matching pattern. If the pattern is never found or if the
/// scanner reaches the end of the string, returns all remaining characters from
/// the starting position to the end.
pub fn[T : Pattern] Scanner::eat_until(self : Scanner, pat : T) -> String {
  let start = self.cursor
  while not(self.done()) && pat.matches(self.after()) is None {
    let _ = self.eat()

  }
  self.from(start)
}

///|
/// Returns a string containing all the whitespace characters that were
/// consumed. If no whitespace characters are found at the current position,
/// returns an empty string.
///
pub fn Scanner::eat_whitespace(self : Scanner) -> String {
  self.eat_while(CharPredicate::new(Char::is_whitespace))
}

///|
/// Consumes a pattern from the scanner if it matches at the current cursor
/// position, otherwise throws an exception.
///
/// Parameters:
///
/// * `self` : The scanner instance.
/// * `pat` : The pattern that must be matched at the current cursor position.
///   Can be a character, string, character array, or character predicate.
///
/// Throws an error of type `Failure` if the pattern does not match at the
/// current cursor position.
pub fn[T : Pattern] Scanner::expect(
  self : Scanner,
  pat : T
) -> Unit raise Failure {
  let len = pat.matches(self.after())
  match len {
    Some(len) => self.cursor += len
    None => pat.expected()
  }
}

///|
/// Sets the scanner's cursor position to the specified target index, ensuring
/// it lands on a valid character boundary.
///
/// Parameters:
///
/// * `self` : The scanner instance to modify.
/// * `target` : The desired cursor position in the string. This value will be
///   automatically adjusted to ensure it falls on a valid character boundary if
///   it would otherwise split a multi-byte character.
///
/// Example:
///
/// ```moonbit
/// let scanner = Scanner::new("hello world")
/// scanner.jump(6)
/// inspect(scanner.peek(), content="Some('w')") // cursor now at 'w'
///
/// // Jumping beyond string length moves cursor to end
/// scanner.jump(100)
/// inspect(scanner.done(), content="true")
/// ```
///
pub fn Scanner::jump(self : Scanner, target : Int) -> Unit {
  self.cursor = self.snap(target)
}

///|
/// Adjusts the given index to ensure it falls on a valid UTF-16 character
/// boundary within the scanner's string.
/// 
/// cos moonbit use utf16, the length of Stirng is different.
/// for example the length of 🦍 is 4 in rust.
/// but in moonbit the length(String) is 2 (🦍.to_bytes().length() is 4)
/// I prefer the former.
/// 
/// Parameters:
///
/// * `self` : The scanner instance.
/// * `index` : The target position to snap to a character boundary. If the
///   index is beyond the string length, it will be clamped to the string's end.
///
/// Returns the adjusted index that falls on a valid character boundary. If the
/// original index would split a UTF-16 surrogate pair, the index is moved
/// backward to the start of the pair.
///
/// Example:
///
/// ```moonbit
/// let scanner = Scanner::new("hello🐶world")
/// inspect(scanner.snap(7), content="7") // Snaps to start of emoji if index falls in middle
/// inspect(scanner.snap(100), content="12") // Clamps to string length
/// inspect(scanner.snap(5), content="5") // Already on boundary, unchanged
/// ```
///
pub fn Scanner::snap(self : Scanner, index : Int) -> Int {
  let len = self.str.length()
  let mut pos = if index >= len { len } else { index }
  if pos > 0 && pos < len {
    let code_unit = self.str.charcode_at(pos)
    if is_low_surrogate(code_unit) {
      let prev_code_unit = self.str.charcode_at(pos - 1)
      if is_high_surrogate(prev_code_unit) {
        pos -= 1
      }
    }
  }
  pos
}

///|
fn is_high_surrogate(code_unit : Int) -> Bool {
  code_unit >= 0xD800 && code_unit <= 0xDBFF
}

///|
fn is_low_surrogate(code_unit : Int) -> Bool {
  code_unit >= 0xDC00 && code_unit <= 0xDFFF
}

///|
impl Show for Scanner with output(self, logger) {
  logger.write_string("Scanner(")
  let (before, after) = self.parts()
  if not(before.is_empty()) {
    logger.write_char('"')
    logger.write_string(before)
    logger.write_char('"')
    logger.write_char(' ')
  }
  logger.write_char('|')
  if not(after.is_empty()) {
    logger.write_char(' ')
    logger.write_char('"')
    logger.write_string(after)
    logger.write_char('"')
  }
  logger.write_char(')')
}

///|
impl Show for Scanner with to_string(self) {
  let mut str = "Scanner("
  let (before, after) = self.parts()
  if not(before.is_empty()) {
    str += "\"\{before}\" "
  }
  str += "|"
  if not(after.is_empty()) {
    str += " \"\{after}\""
  }
  str += ")"
  str
}

///|
pub(open) trait Pattern {
  matches(Self, str : String) -> Int?
  expected(Self) -> Unit raise Failure
}

///|
pub struct CharPredicate {
  pred : (Char) -> Bool
}

///|
pub impl Pattern for CharPredicate with matches(self, str : String) {
  guard not(str.is_empty()) && (self.pred)(str.char_at(0)) else { None }
  Some(str.char_at(0).to_string().length())
}

///|
pub impl Pattern for CharPredicate with expected(self) {
  // just to avoid warning
  let mut flag = (self.pred)('a')
  if flag == true {
    flag = false
  }
  fail("expected closure to return `true` but `\{flag}`")
}

///|
pub impl Pattern for Char with matches(self, str : String) {
  if str.has_prefix(self.to_string()) {
    Some(self.to_string().length())
  } else {
    None
  }
}

///|
pub impl Pattern for Char with expected(self) {
  fail("expected \{self}")
}

///|
pub impl Pattern for String with matches(self, str : String) -> Int? {
  if str.has_prefix(self) {
    Some(self.length())
  } else {
    None
  }
}

///|
pub impl Pattern for String with expected(self) {
  fail("expected \{self}")
}

///|
pub impl Pattern for Array[Char] with matches(self, str : String) {
  guard str != "" else { None }
  let next = str.char_at(0)
  if self.search(next) is Some(_) {
    Some(next.to_string().length())
  } else {
    None
  }
}

///|
pub impl Pattern for Array[Char] with expected(self) {
  if self.is_empty() {
    fail("empty array cannot match")
  } else {
    fail("expected one element of \{self}")
  }
}

///|
/// Wrapper for character predicates that can be used in pattern matching
/// operations.
///
/// Fields:
///
/// * `pred` : Function that tests whether a character satisfies a specific
///   condition.
// pub struct CharPredicate {
//   pred : (Char) -> Bool
// }

///|
/// Creates a new character predicate that wraps a function for testing
/// characters.
///
/// Parameters:
///
/// * `f` : A function that takes a character and returns a boolean indicating
///   whether the character satisfies the predicate condition.
///
/// Returns a `CharPredicate` instance that can be used with pattern matching
/// operations in the scanner.
pub fn CharPredicate::new(f : (Char) -> Bool) -> CharPredicate {
  { pred: f }
}

///|
test "test_fmt" {
  let s = Scanner::new("hello world")
  let test_1 =
    #|Scanner(| "hello world")
  assert_eq(s.to_string(), test_1)
  let _ = s.eat_while(CharPredicate::new(Char::is_ascii_alphabetic))
  let test_2 =
    #|Scanner("hello" | " world")
  assert_eq(s.to_string(), test_2)
  let f : (Char) -> Bool = _ => true
  let pred = CharPredicate::new(f)
  let _ = s.eat_while(pred)
  let test_3 =
    #|Scanner("hello world" |)
  assert_eq(s.to_string(), test_3)
}

///|
test "test_empty" {
  let s = Scanner::new("")
  assert_eq(s.cursor, 0)
  assert_eq(s.done(), true)
  assert_eq(s.before(), "")
  assert_eq(s.after(), "")
  assert_eq(s.from(0), "")
  assert_eq(s.from(10), "")
  assert_eq(s.to(10), "")
  assert_eq(s.to(10), "")
  assert_eq(s.get(10, 20), "")
  assert_eq(s.at(""), true)
  assert_eq(s.at('a'), false)
  let f : (Char) -> Bool = _ => true
  let pred = CharPredicate::new(f)
  assert_eq(s.at(pred), false)
  assert_eq(s.scout(-1), None)
  assert_eq(s.scout(-1), None)
  assert_eq(s.scout(1), None)
  assert_eq(s.locate(-1), 0)
  assert_eq(s.locate(0), 0)
  assert_eq(s.locate(1), 0)
  assert_eq(s.eat(), None)
  assert_eq(s.uneat(), None)
  assert_eq(s.eat_if(""), true)
  assert_eq(s.eat_if('a'), false)
  assert_eq(s.eat_while(""), "")
  assert_eq(s.eat_while('a'), "")
  assert_eq(s.eat_until(""), "")
  assert_eq(s.eat_whitespace(), "")
}

///|
test "test_slice" {
  let s = Scanner::new("zoo 🦍🌴🎍 party")
  assert_eq(s.parts(), ("", "zoo 🦍🌴🎍 party"))
  assert_eq(s.get(2, 6), "o 🦍")
  assert_eq(s.get(2, 22), "o 🦍🌴🎍 party")
  let _ = s.eat_while(CharPredicate::new(Char::is_ascii))
  assert_eq(s.parts(), ("zoo ", "🦍🌴🎍 party"))
  assert_eq(s.from(1), "oo ")
  assert_eq(s.to(9), "🦍🌴")
  assert_eq(s.to(10), "🦍🌴🎍")
  assert_eq(s.to(11), "🦍🌴🎍 ")
  assert_eq(s.to(65536), "🦍🌴🎍 party")
  let _ = s.eat_until(CharPredicate::new(Char::is_whitespace))
  assert_eq(s.parts(), ("zoo 🦍🌴🎍", " party"))
  assert_eq(s.from(3), " 🦍🌴🎍")
}

///|
test "test_done_and_peek" {
  let s = Scanner::new("äbc")
  assert_eq(s.done(), false)
  assert_eq(s.peek(), Some('ä'))
  let _ = s.eat()
  assert_eq(s.done(), false)
  assert_eq(s.peek(), Some('b'))
  let _ = s.eat()
  assert_eq(s.done(), false)
  assert_eq(s.peek(), Some('c'))
  let _ = s.eat()
  assert_eq(s.done(), true)
  assert_eq(s.peek(), None)
}

///|
test "test_at" {
  let s = Scanner::new("Ђ12")
  assert_true(s.at('Ђ'))
  assert_true(s.at(['b', 'Ђ', 'Њ']))
  assert_true(s.at("Ђ"))
  assert_true(s.at("Ђ1"))
  assert_true(!s.at("a13"))
  assert_true(!s.at(CharPredicate::new(Char::is_numeric)))
  let _ = s.eat()
  assert_true(s.at(CharPredicate::new(Char::is_numeric)))
  assert_true(s.at(CharPredicate::new(Char::is_ascii_digit)))
}

///|
test "test_scout_and_locate" {
  let s = Scanner::new("a🐆c1Ф")
  let _ = s.eat_until(CharPredicate::new(Char::is_numeric))
  assert_eq(s.scout(-4), None)
  assert_eq(s.scout(-3), Some('a'))
  assert_eq(s.scout(-2), Some('🐆'))
  assert_eq(s.scout(-1), Some('c'))
  assert_eq(s.scout(0), Some('1'))
  assert_eq(s.scout(1), Some('Ф'))
  assert_eq(s.scout(2), None)
  assert_eq(s.locate(-4), 0)
  assert_eq(s.locate(-3), 0)
  assert_eq(s.locate(-2), 2)
  assert_eq(s.locate(-1), 6)
  assert_eq(s.locate(0), 8)
  assert_eq(s.locate(1), 10)
  assert_eq(s.locate(2), 12)
  assert_eq(s.locate(3), 12)
}

///|
test "test_eat_and_uneat" {
  let s = Scanner::new("🐶🐱🐭")
  assert_eq(s.eat(), Some('🐶'))
  let _ = s.jump(65536)
  assert_eq(s.uneat(), Some('🐭'))
  assert_eq(s.uneat(), Some('🐱'))
  assert_eq(s.uneat(), Some('🐶'))
  assert_eq(s.uneat(), None)
  assert_eq(s.eat(), Some('🐶'))
}

///|
test "test_conditional_and_looping" {
  let s = Scanner::new("abc123def33")
  assert_eq(s.eat_if('b'), false)
  assert_eq(s.eat_if('a'), true)
  assert_eq(s.eat_while(['a', 'b', 'c']), "bc")
  assert_eq(s.eat_while(CharPredicate::new(Char::is_numeric)), "123")
  assert_eq(s.eat_until(CharPredicate::new(Char::is_numeric)), "def")
  assert_eq(s.eat_while('3'), "33")
}

///|
test "test_eat_whitespace" {
  let s = Scanner::new("ab  \n  b\tc")
  assert_eq(s.eat_whitespace(), "")
  assert_eq(s.eat_while(CharPredicate::new(Char::is_ascii_alphabetic)), "ab")
  assert_eq(s.eat_whitespace(), "  \n  ")
  assert_eq(s.eat_if('b'), true)
  assert_eq(s.eat_whitespace(), "\t")
  assert_eq(s.eat_while(CharPredicate::new(Char::is_ascii_alphabetic)), "c")
}

///|
test "test_expect_okay" {
  let s = Scanner::new("🦚12")
  s.expect('🦚')
  s.jump(1)
  s.expect("🦚")
  assert_eq(s.after(), "12")
}

///|
test "test_expect_char_fail" {
  let mut flag : Bool = false
  try {
    let s = Scanner::new("no turtle in sight")
    s.expect('🐢')
  } catch {
    Failure(_) => flag = true
  }
  assert_true(flag)
}

///|
test "test_expect_str_fail" {
  let mut flag : Bool = false
  try {
    let s = Scanner::new("no turtle in sight")
    s.expect("🐢")
  } catch {
    Failure(_) => flag = true
  }
  assert_true(flag)
}

///|
test "test_expect_array_fail" {
  let mut flag : Bool = false
  try {
    let s = Scanner::new("")
    s.expect(['a'])
  } catch {
    Failure(_) => flag = true
  }
  assert_true(flag)
}

///|
test "test_expect_array_fail" {
  let mut flag : Bool = false
  try {
    let s = Scanner::new("no turtle or dolphin in sight")
    s.expect(['🐢', '🐬'])
  } catch {
    Failure(_) => flag = true
  }
  assert_true(flag)
}

///|
test "test_expect_closure_fail" {
  let mut flag : Bool = false
  try {
    let s = Scanner::new("no numbers in sight")
    s.expect(CharPredicate::new(Char::is_numeric))
  } catch {
    Failure(_) => flag = true
  }
  assert_true(flag)
}
