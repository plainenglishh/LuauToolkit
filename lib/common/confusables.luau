--[[
    Adapted from luau/Ast/src/Confusables.cpp, which itself is derived from
    http://www.unicode.org/Public/security/10.0.0/confusables.txt
]]
local confusables = {
    {codepoint = 34, with = "\""},      -- MA#* ( with = " → '' ) QUOTATION MARK → APOSTROPHE, APOSTROPHE# # Converted to a quote.
    {codepoint = 48, with = "O"},       -- MA# ( 0 → O ) DIGIT ZERO → LATIN CAPITAL LETTER O#
    {codepoint = 49, with = "l"},       -- MA# ( 1 → l ) DIGIT ONE → LATIN SMALL LETTER L#
    {codepoint = 73, with = "l"},       -- MA# ( I → l ) LATIN CAPITAL LETTER I → LATIN SMALL LETTER L#
    {codepoint = 96, with = "'"},       -- MA#* ( ` → ' ) GRAVE ACCENT → APOSTROPHE# →ˋ→→｀→→‘→
    {codepoint = 109, with = "rn"},     -- MA# ( m → rn ) LATIN SMALL LETTER M → LATIN SMALL LETTER R, LATIN SMALL LETTER N#
    {codepoint = 124, with = "l"},      -- MA#* ( | → l ) VERTICAL LINE → LATIN SMALL LETTER L#
    {codepoint = 160, with = " "},      -- MA#* (   →   ) NO-BREAK SPACE → SPACE#
    {codepoint = 180, with = "'"},      -- MA#* ( ´ → ' ) ACUTE ACCENT → APOSTROPHE# →΄→→ʹ→
    {codepoint = 184, with = ","},      -- MA#* ( ¸ → , ) CEDILLA → COMMA#
    {codepoint = 198, with = "AE"},     -- MA# ( Æ → AE ) LATIN CAPITAL LETTER AE → LATIN CAPITAL LETTER A, LATIN CAPITAL LETTER E#
    {codepoint = 215, with = "x"},      -- MA#* ( × → x ) MULTIPLICATION SIGN → LATIN SMALL LETTER X#
    {codepoint = 230, with = "ae"},     -- MA# ( æ → ae ) LATIN SMALL LETTER AE → LATIN SMALL LETTER A, LATIN SMALL LETTER E#
    {codepoint = 305, with = "i"},      -- MA# ( ı → i ) LATIN SMALL LETTER DOTLESS I → LATIN SMALL LETTER I#
    {codepoint = 306, with = "lJ"},     -- MA# ( Ĳ → lJ ) LATIN CAPITAL LIGATURE IJ → LATIN SMALL LETTER L, LATIN CAPITAL LETTER J# →IJ→
    {codepoint = 307, with = "ij"},     -- MA# ( ĳ → ij ) LATIN SMALL LIGATURE IJ → LATIN SMALL LETTER I, LATIN SMALL LETTER J#
    {codepoint = 329, with = "'n"},     -- MA# ( ŉ → 'n ) LATIN SMALL LETTER N PRECEDED BY APOSTROPHE → APOSTROPHE, LATIN SMALL LETTER N# →ʼn→
    {codepoint = 338, with = "OE"},     -- MA# ( Œ → OE ) LATIN CAPITAL LIGATURE OE → LATIN CAPITAL LETTER O, LATIN CAPITAL LETTER E#
    {codepoint = 339, with = "oe"},     -- MA# ( œ → oe ) LATIN SMALL LIGATURE OE → LATIN SMALL LETTER O, LATIN SMALL LETTER E#
    {codepoint = 383, with = "f"},      -- MA# ( ſ → f ) LATIN SMALL LETTER LONG S → LATIN SMALL LETTER F#
    {codepoint = 385, with = "'B"},     -- MA# ( Ɓ → 'B ) LATIN CAPITAL LETTER B WITH HOOK → APOSTROPHE, LATIN CAPITAL LETTER B# →ʽB→
    {codepoint = 388, with = "b"},      -- MA# ( Ƅ → b ) LATIN CAPITAL LETTER TONE SIX → LATIN SMALL LETTER B#
    {codepoint = 391, with = "C'"},     -- MA# ( Ƈ → C' ) LATIN CAPITAL LETTER C WITH HOOK → LATIN CAPITAL LETTER C, APOSTROPHE# →Cʽ→
    {codepoint = 394, with = "'D"},     -- MA# ( Ɗ → 'D ) LATIN CAPITAL LETTER D WITH HOOK → APOSTROPHE, LATIN CAPITAL LETTER D# →ʽD→
    {codepoint = 397, with = "g"},      -- MA# ( ƍ → g ) LATIN SMALL LETTER TURNED DELTA → LATIN SMALL LETTER G#
    {codepoint = 403, with = "G'"},     -- MA# ( Ɠ → G' ) LATIN CAPITAL LETTER G WITH HOOK → LATIN CAPITAL LETTER G, APOSTROPHE# →Gʽ→
    {codepoint = 406, with = "l"},      -- MA# ( Ɩ → l ) LATIN CAPITAL LETTER IOTA → LATIN SMALL LETTER L#
    {codepoint = 408, with = "K'"},     -- MA# ( Ƙ → K' ) LATIN CAPITAL LETTER K WITH HOOK → LATIN CAPITAL LETTER K, APOSTROPHE# →Kʽ→
    {codepoint = 416, with = "O'"},     -- MA# ( Ơ → O' ) LATIN CAPITAL LETTER O WITH HORN → LATIN CAPITAL LETTER O, APOSTROPHE# →Oʼ→
    {codepoint = 417, with = "o'"},     -- MA# ( ơ → o' ) LATIN SMALL LETTER O WITH HORN → LATIN SMALL LETTER O, APOSTROPHE# →oʼ→
    {codepoint = 420, with = "'P"},     -- MA# ( Ƥ → 'P ) LATIN CAPITAL LETTER P WITH HOOK → APOSTROPHE, LATIN CAPITAL LETTER P# →ʽP→
    {codepoint = 422, with = "R"},      -- MA# ( Ʀ → R ) LATIN LETTER YR → LATIN CAPITAL LETTER R#
    {codepoint = 423, with = "2"},      -- MA# ( Ƨ → 2 ) LATIN CAPITAL LETTER TONE TWO → DIGIT TWO#
    {codepoint = 428, with = "'T"},     -- MA# ( Ƭ → 'T ) LATIN CAPITAL LETTER T WITH HOOK → APOSTROPHE, LATIN CAPITAL LETTER T# →ʽT→
    {codepoint = 435, with = "'Y"},     -- MA# ( Ƴ → 'Y ) LATIN CAPITAL LETTER Y WITH HOOK → APOSTROPHE, LATIN CAPITAL LETTER Y# →ʽY→
    {codepoint = 439, with = "3"},      -- MA# ( Ʒ → 3 ) LATIN CAPITAL LETTER EZH → DIGIT THREE#
    {codepoint = 444, with = "5"},      -- MA# ( Ƽ → 5 ) LATIN CAPITAL LETTER TONE FIVE → DIGIT FIVE#
    {codepoint = 445, with = "s"},      -- MA# ( ƽ → s ) LATIN SMALL LETTER TONE FIVE → LATIN SMALL LETTER S#
    {codepoint = 448, with = "l"},      -- MA# ( ǀ → l ) LATIN LETTER DENTAL CLICK → LATIN SMALL LETTER L#
    {codepoint = 449, with = "ll"},     -- MA# ( ǁ → ll ) LATIN LETTER LATERAL CLICK → LATIN SMALL LETTER L, LATIN SMALL LETTER L# →‖→→∥→→||→
    {codepoint = 451, with = "!"},      -- MA# ( ǃ → ! ) LATIN LETTER RETROFLEX CLICK → EXCLAMATION MARK#
    {codepoint = 455, with = "LJ"},     -- MA# ( Ǉ → LJ ) LATIN CAPITAL LETTER LJ → LATIN CAPITAL LETTER L, LATIN CAPITAL LETTER J#
    {codepoint = 456, with = "Lj"},     -- MA# ( ǈ → Lj ) LATIN CAPITAL LETTER L WITH SMALL LETTER J → LATIN CAPITAL LETTER L, LATIN SMALL LETTER J#
    {codepoint = 457, with = "lj"},     -- MA# ( ǉ → lj ) LATIN SMALL LETTER LJ → LATIN SMALL LETTER L, LATIN SMALL LETTER J#
    {codepoint = 458, with = "NJ"},     -- MA# ( Ǌ → NJ ) LATIN CAPITAL LETTER NJ → LATIN CAPITAL LETTER N, LATIN CAPITAL LETTER J#
    {codepoint = 459, with = "Nj"},     -- MA# ( ǋ → Nj ) LATIN CAPITAL LETTER N WITH SMALL LETTER J → LATIN CAPITAL LETTER N, LATIN SMALL LETTER J#
    {codepoint = 460, with = "nj"},     -- MA# ( ǌ → nj ) LATIN SMALL LETTER NJ → LATIN SMALL LETTER N, LATIN SMALL LETTER J#
    {codepoint = 497, with = "DZ"},     -- MA# ( Ǳ → DZ ) LATIN CAPITAL LETTER DZ → LATIN CAPITAL LETTER D, LATIN CAPITAL LETTER Z#
    {codepoint = 498, with = "Dz"},     -- MA# ( ǲ → Dz ) LATIN CAPITAL LETTER D WITH SMALL LETTER Z → LATIN CAPITAL LETTER D, LATIN SMALL LETTER Z#
    {codepoint = 499, with = "dz"},     -- MA# ( ǳ → dz ) LATIN SMALL LETTER DZ → LATIN SMALL LETTER D, LATIN SMALL LETTER Z#
    {codepoint = 540, with = "3"},      -- MA# ( Ȝ → 3 ) LATIN CAPITAL LETTER YOGH → DIGIT THREE# →Ʒ→
    {codepoint = 546, with = "8"},      -- MA# ( Ȣ → 8 ) LATIN CAPITAL LETTER OU → DIGIT EIGHT#
    {codepoint = 547, with = "8"},      -- MA# ( ȣ → 8 ) LATIN SMALL LETTER OU → DIGIT EIGHT#
    {codepoint = 577, with = "?"},      -- MA# ( Ɂ → ? ) LATIN CAPITAL LETTER GLOTTAL STOP → QUESTION MARK# →ʔ→
    {codepoint = 593, with = "a"},      -- MA# ( ɑ → a ) LATIN SMALL LETTER ALPHA → LATIN SMALL LETTER A#
    {codepoint = 609, with = "g"},      -- MA# ( ɡ → g ) LATIN SMALL LETTER SCRIPT G → LATIN SMALL LETTER G#
    {codepoint = 611, with = "y"},      -- MA# ( ɣ → y ) LATIN SMALL LETTER GAMMA → LATIN SMALL LETTER Y# →γ→
    {codepoint = 617, with = "i"},      -- MA# ( ɩ → i ) LATIN SMALL LETTER IOTA → LATIN SMALL LETTER I#
    {codepoint = 618, with = "i"},      -- MA# ( ɪ → i ) LATIN LETTER SMALL CAPITAL I → LATIN SMALL LETTER I# →ı→
    {codepoint = 623, with = "w"},      -- MA# ( ɯ → w ) LATIN SMALL LETTER TURNED M → LATIN SMALL LETTER W#
    {codepoint = 651, with = "u"},      -- MA# ( ʋ → u ) LATIN SMALL LETTER V WITH HOOK → LATIN SMALL LETTER U#
    {codepoint = 655, with = "y"},      -- MA# ( ʏ → y ) LATIN LETTER SMALL CAPITAL Y → LATIN SMALL LETTER Y# →ү→→γ→
    {codepoint = 660, with = "?"},      -- MA# ( ʔ → ? ) LATIN LETTER GLOTTAL STOP → QUESTION MARK#
    {codepoint = 675, with = "dz"},     -- MA# ( ʣ → dz ) LATIN SMALL LETTER DZ DIGRAPH → LATIN SMALL LETTER D, LATIN SMALL LETTER Z#
    {codepoint = 678, with = "ts"},     -- MA# ( ʦ → ts ) LATIN SMALL LETTER TS DIGRAPH → LATIN SMALL LETTER T, LATIN SMALL LETTER S#
    {codepoint = 682, with = "ls"},     -- MA# ( ʪ → ls ) LATIN SMALL LETTER LS DIGRAPH → LATIN SMALL LETTER L, LATIN SMALL LETTER S#
    {codepoint = 683, with = "lz"},     -- MA# ( ʫ → lz ) LATIN SMALL LETTER LZ DIGRAPH → LATIN SMALL LETTER L, LATIN SMALL LETTER Z#
    {codepoint = 697, with = "'"},      -- MA# ( ʹ → ' ) MODIFIER LETTER PRIME → APOSTROPHE#
    {codepoint = 698, with = "\""},     -- MA# ( ʺ → '' ) MODIFIER LETTER DOUBLE PRIME → APOSTROPHE, APOSTROPHE# →with = "→# Converted to a quote.
    {codepoint = 699, with = "'"},      -- MA# ( ʻ → ' ) MODIFIER LETTER TURNED COMMA → APOSTROPHE# →‘→
    {codepoint = 700, with = "'"},      -- MA# ( ʼ → ' ) MODIFIER LETTER APOSTROPHE → APOSTROPHE# →′→
    {codepoint = 701, with = "'"},      -- MA# ( ʽ → ' ) MODIFIER LETTER REVERSED COMMA → APOSTROPHE# →‘→
    {codepoint = 702, with = "'"},      -- MA# ( ʾ → ' ) MODIFIER LETTER RIGHT HALF RING → APOSTROPHE# →ʼ→→′→
    {codepoint = 706, with = "<"},      -- MA#* ( ˂ → < ) MODIFIER LETTER LEFT ARROWHEAD → LESS-THAN SIGN#
    {codepoint = 707, with = ">"},      -- MA#* ( ˃ → > ) MODIFIER LETTER RIGHT ARROWHEAD → GREATER-THAN SIGN#
    {codepoint = 708, with = "^"},      -- MA#* ( ˄ → ^ ) MODIFIER LETTER UP ARROWHEAD → CIRCUMFLEX ACCENT#
    {codepoint = 710, with = "^"},      -- MA# ( ˆ → ^ ) MODIFIER LETTER CIRCUMFLEX ACCENT → CIRCUMFLEX ACCENT#
    {codepoint = 712, with = "'"},      -- MA# ( ˈ → ' ) MODIFIER LETTER VERTICAL LINE → APOSTROPHE#
    {codepoint = 714, with = "'"},      -- MA# ( ˊ → ' ) MODIFIER LETTER ACUTE ACCENT → APOSTROPHE# →ʹ→→′→
    {codepoint = 715, with = "'"},      -- MA# ( ˋ → ' ) MODIFIER LETTER GRAVE ACCENT → APOSTROPHE# →｀→→‘→
    {codepoint = 720, with = ":"},      -- MA# ( ː → : ) MODIFIER LETTER TRIANGULAR COLON → COLON#
    {codepoint = 727, with = "-"},      -- MA#* ( ˗ → - ) MODIFIER LETTER MINUS SIGN → HYPHEN-MINUS#
    {codepoint = 731, with = "i"},      -- MA#* ( ˛ → i ) OGONEK → LATIN SMALL LETTER I# →ͺ→→ι→→ι→
    {codepoint = 732, with = "~"},      -- MA#* ( ˜ → ~ ) SMALL TILDE → TILDE#
    {codepoint = 733, with = "\""},     -- MA#* ( ˝ → '' ) DOUBLE ACUTE ACCENT → APOSTROPHE, APOSTROPHE# →with = "→# Converted to a quote.
    {codepoint = 750, with = "\""},     -- MA# ( ˮ → '' ) MODIFIER LETTER DOUBLE APOSTROPHE → APOSTROPHE, APOSTROPHE# →″→→with = "→# Converted to a quote.
    {codepoint = 756, with = "'"},      -- MA#* ( ˴ → ' ) MODIFIER LETTER MIDDLE GRAVE ACCENT → APOSTROPHE# →ˋ→→｀→→‘→
    {codepoint = 758, with = "\""},     -- MA#* ( ˶ → '' ) MODIFIER LETTER MIDDLE DOUBLE ACUTE ACCENT → APOSTROPHE, APOSTROPHE# →˝→→with = "→# Converted to a quote.
    {codepoint = 760, with = ":"},      -- MA#* ( ˸ → : ) MODIFIER LETTER RAISED COLON → COLON#
    {codepoint = 884, with = "'"},      -- MA# ( ʹ → ' ) GREEK NUMERAL SIGN → APOSTROPHE# →′→
    {codepoint = 890, with = "i"},      -- MA#* ( ͺ → i ) GREEK YPOGEGRAMMENI → LATIN SMALL LETTER I# →ι→→ι→
    {codepoint = 894, with = ";"},      -- MA#* ( ; → ; ) GREEK QUESTION MARK → SEMICOLON#
    {codepoint = 895, with = "J"},      -- MA# ( Ϳ → J ) GREEK CAPITAL LETTER YOT → LATIN CAPITAL LETTER J#
    {codepoint = 900, with = "'"},      -- MA#* ( ΄ → ' ) GREEK TONOS → APOSTROPHE# →ʹ→
    {codepoint = 913, with = "A"},      -- MA# ( Α → A ) GREEK CAPITAL LETTER ALPHA → LATIN CAPITAL LETTER A#
    {codepoint = 914, with = "B"},      -- MA# ( Β → B ) GREEK CAPITAL LETTER BETA → LATIN CAPITAL LETTER B#
    {codepoint = 917, with = "E"},      -- MA# ( Ε → E ) GREEK CAPITAL LETTER EPSILON → LATIN CAPITAL LETTER E#
    {codepoint = 918, with = "Z"},      -- MA# ( Ζ → Z ) GREEK CAPITAL LETTER ZETA → LATIN CAPITAL LETTER Z#
    {codepoint = 919, with = "H"},      -- MA# ( Η → H ) GREEK CAPITAL LETTER ETA → LATIN CAPITAL LETTER H#
    {codepoint = 921, with = "l"},      -- MA# ( Ι → l ) GREEK CAPITAL LETTER IOTA → LATIN SMALL LETTER L#
    {codepoint = 922, with = "K"},      -- MA# ( Κ → K ) GREEK CAPITAL LETTER KAPPA → LATIN CAPITAL LETTER K#
    {codepoint = 924, with = "M"},      -- MA# ( Μ → M ) GREEK CAPITAL LETTER MU → LATIN CAPITAL LETTER M#
    {codepoint = 925, with = "N"},      -- MA# ( Ν → N ) GREEK CAPITAL LETTER NU → LATIN CAPITAL LETTER N#
    {codepoint = 927, with = "O"},      -- MA# ( Ο → O ) GREEK CAPITAL LETTER OMICRON → LATIN CAPITAL LETTER O#
    {codepoint = 929, with = "P"},      -- MA# ( Ρ → P ) GREEK CAPITAL LETTER RHO → LATIN CAPITAL LETTER P#
    {codepoint = 932, with = "T"},      -- MA# ( Τ → T ) GREEK CAPITAL LETTER TAU → LATIN CAPITAL LETTER T#
    {codepoint = 933, with = "Y"},      -- MA# ( Υ → Y ) GREEK CAPITAL LETTER UPSILON → LATIN CAPITAL LETTER Y#
    {codepoint = 935, with = "X"},      -- MA# ( Χ → X ) GREEK CAPITAL LETTER CHI → LATIN CAPITAL LETTER X#
    {codepoint = 945, with = "a"},      -- MA# ( α → a ) GREEK SMALL LETTER ALPHA → LATIN SMALL LETTER A#
    {codepoint = 947, with = "y"},      -- MA# ( γ → y ) GREEK SMALL LETTER GAMMA → LATIN SMALL LETTER Y#
    {codepoint = 953, with = "i"},      -- MA# ( ι → i ) GREEK SMALL LETTER IOTA → LATIN SMALL LETTER I#
    {codepoint = 957, with = "v"},      -- MA# ( ν → v ) GREEK SMALL LETTER NU → LATIN SMALL LETTER V#
    {codepoint = 959, with = "o"},      -- MA# ( ο → o ) GREEK SMALL LETTER OMICRON → LATIN SMALL LETTER O#
    {codepoint = 961, with = "p"},      -- MA# ( ρ → p ) GREEK SMALL LETTER RHO → LATIN SMALL LETTER P#
    {codepoint = 963, with = "o"},      -- MA# ( σ → o ) GREEK SMALL LETTER SIGMA → LATIN SMALL LETTER O#
    {codepoint = 965, with = "u"},      -- MA# ( υ → u ) GREEK SMALL LETTER UPSILON → LATIN SMALL LETTER U# →ʋ→
    {codepoint = 978, with = "Y"},      -- MA# ( ϒ → Y ) GREEK UPSILON WITH HOOK SYMBOL → LATIN CAPITAL LETTER Y#
    {codepoint = 988, with = "F"},      -- MA# ( Ϝ → F ) GREEK LETTER DIGAMMA → LATIN CAPITAL LETTER F#
    {codepoint = 1000, with = "2"},     -- MA# ( Ϩ → 2 ) COPTIC CAPITAL LETTER HORI → DIGIT TWO# →Ƨ→
    {codepoint = 1009, with = "p"},     -- MA# ( ϱ → p ) GREEK RHO SYMBOL → LATIN SMALL LETTER P# →ρ→
    {codepoint = 1010, with = "c"},     -- MA# ( ϲ → c ) GREEK LUNATE SIGMA SYMBOL → LATIN SMALL LETTER C#
    {codepoint = 1011, with = "j"},     -- MA# ( ϳ → j ) GREEK LETTER YOT → LATIN SMALL LETTER J#
    {codepoint = 1017, with = "C"},     -- MA# ( Ϲ → C ) GREEK CAPITAL LUNATE SIGMA SYMBOL → LATIN CAPITAL LETTER C#
    {codepoint = 1018, with = "M"},     -- MA# ( Ϻ → M ) GREEK CAPITAL LETTER SAN → LATIN CAPITAL LETTER M#
    {codepoint = 1029, with = "S"},     -- MA# ( Ѕ → S ) CYRILLIC CAPITAL LETTER DZE → LATIN CAPITAL LETTER S#
    {codepoint = 1030, with = "l"},     -- MA# ( І → l ) CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I → LATIN SMALL LETTER L#
    {codepoint = 1032, with = "J"},     -- MA# ( Ј → J ) CYRILLIC CAPITAL LETTER JE → LATIN CAPITAL LETTER J#
    {codepoint = 1040, with = "A"},     -- MA# ( А → A ) CYRILLIC CAPITAL LETTER A → LATIN CAPITAL LETTER A#
    {codepoint = 1042, with = "B"},     -- MA# ( В → B ) CYRILLIC CAPITAL LETTER VE → LATIN CAPITAL LETTER B#
    {codepoint = 1045, with = "E"},     -- MA# ( Е → E ) CYRILLIC CAPITAL LETTER IE → LATIN CAPITAL LETTER E#
    {codepoint = 1047, with = "3"},     -- MA# ( З → 3 ) CYRILLIC CAPITAL LETTER ZE → DIGIT THREE#
    {codepoint = 1050, with = "K"},     -- MA# ( К → K ) CYRILLIC CAPITAL LETTER KA → LATIN CAPITAL LETTER K#
    {codepoint = 1052, with = "M"},     -- MA# ( М → M ) CYRILLIC CAPITAL LETTER EM → LATIN CAPITAL LETTER M#
    {codepoint = 1053, with = "H"},     -- MA# ( Н → H ) CYRILLIC CAPITAL LETTER EN → LATIN CAPITAL LETTER H#
    {codepoint = 1054, with = "O"},     -- MA# ( О → O ) CYRILLIC CAPITAL LETTER O → LATIN CAPITAL LETTER O#
    {codepoint = 1056, with = "P"},     -- MA# ( Р → P ) CYRILLIC CAPITAL LETTER ER → LATIN CAPITAL LETTER P#
    {codepoint = 1057, with = "C"},     -- MA# ( С → C ) CYRILLIC CAPITAL LETTER ES → LATIN CAPITAL LETTER C#
    {codepoint = 1058, with = "T"},     -- MA# ( Т → T ) CYRILLIC CAPITAL LETTER TE → LATIN CAPITAL LETTER T#
    {codepoint = 1059, with = "Y"},     -- MA# ( У → Y ) CYRILLIC CAPITAL LETTER U → LATIN CAPITAL LETTER Y#
    {codepoint = 1061, with = "X"},     -- MA# ( Х → X ) CYRILLIC CAPITAL LETTER HA → LATIN CAPITAL LETTER X#
    {codepoint = 1067, with = "bl"},    -- MA# ( Ы → bl ) CYRILLIC CAPITAL LETTER YERU → LATIN SMALL LETTER B, LATIN SMALL LETTER L# →ЬІ→→Ь1→
    {codepoint = 1068, with = "b"},     -- MA# ( Ь → b ) CYRILLIC CAPITAL LETTER SOFT SIGN → LATIN SMALL LETTER B# →Ƅ→
    {codepoint = 1070, with = "lO"},    -- MA# ( Ю → lO ) CYRILLIC CAPITAL LETTER YU → LATIN SMALL LETTER L, LATIN CAPITAL LETTER O# →IO→
    {codepoint = 1072, with = "a"},     -- MA# ( а → a ) CYRILLIC SMALL LETTER A → LATIN SMALL LETTER A#
    {codepoint = 1073, with = "6"},     -- MA# ( б → 6 ) CYRILLIC SMALL LETTER BE → DIGIT SIX#
    {codepoint = 1075, with = "r"},     -- MA# ( г → r ) CYRILLIC SMALL LETTER GHE → LATIN SMALL LETTER R#
    {codepoint = 1077, with = "e"},     -- MA# ( е → e ) CYRILLIC SMALL LETTER IE → LATIN SMALL LETTER E#
    {codepoint = 1086, with = "o"},     -- MA# ( о → o ) CYRILLIC SMALL LETTER O → LATIN SMALL LETTER O#
    {codepoint = 1088, with = "p"},     -- MA# ( р → p ) CYRILLIC SMALL LETTER ER → LATIN SMALL LETTER P#
    {codepoint = 1089, with = "c"},     -- MA# ( с → c ) CYRILLIC SMALL LETTER ES → LATIN SMALL LETTER C#
    {codepoint = 1091, with = "y"},     -- MA# ( у → y ) CYRILLIC SMALL LETTER U → LATIN SMALL LETTER Y#
    {codepoint = 1093, with = "x"},     -- MA# ( х → x ) CYRILLIC SMALL LETTER HA → LATIN SMALL LETTER X#
    {codepoint = 1109, with = "s"},     -- MA# ( ѕ → s ) CYRILLIC SMALL LETTER DZE → LATIN SMALL LETTER S#
    {codepoint = 1110, with = "i"},     -- MA# ( і → i ) CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I → LATIN SMALL LETTER I#
    {codepoint = 1112, with = "j"},     -- MA# ( ј → j ) CYRILLIC SMALL LETTER JE → LATIN SMALL LETTER J#
    {codepoint = 1121, with = "w"},     -- MA# ( ѡ → w ) CYRILLIC SMALL LETTER OMEGA → LATIN SMALL LETTER W#
    {codepoint = 1140, with = "V"},     -- MA# ( Ѵ → V ) CYRILLIC CAPITAL LETTER IZHITSA → LATIN CAPITAL LETTER V#
    {codepoint = 1141, with = "v"},     -- MA# ( ѵ → v ) CYRILLIC SMALL LETTER IZHITSA → LATIN SMALL LETTER V#
    {codepoint = 1169, with = "r'"},    -- MA# ( ґ → r' ) CYRILLIC SMALL LETTER GHE WITH UPTURN → LATIN SMALL LETTER R, APOSTROPHE# →гˈ→
    {codepoint = 1198, with = "Y"},     -- MA# ( Ү → Y ) CYRILLIC CAPITAL LETTER STRAIGHT U → LATIN CAPITAL LETTER Y#
    {codepoint = 1199, with = "y"},     -- MA# ( ү → y ) CYRILLIC SMALL LETTER STRAIGHT U → LATIN SMALL LETTER Y# →γ→
    {codepoint = 1211, with = "h"},     -- MA# ( һ → h ) CYRILLIC SMALL LETTER SHHA → LATIN SMALL LETTER H#
    {codepoint = 1213, with = "e"},     -- MA# ( ҽ → e ) CYRILLIC SMALL LETTER ABKHASIAN CHE → LATIN SMALL LETTER E#
    {codepoint = 1216, with = "l"},     -- MA# ( Ӏ → l ) CYRILLIC LETTER PALOCHKA → LATIN SMALL LETTER L#
    {codepoint = 1231, with = "i"},     -- MA# ( ӏ → i ) CYRILLIC SMALL LETTER PALOCHKA → LATIN SMALL LETTER I# →ı→
    {codepoint = 1236, with = "AE"},    -- MA# ( Ӕ → AE ) CYRILLIC CAPITAL LIGATURE A IE → LATIN CAPITAL LETTER A, LATIN CAPITAL LETTER E# →Æ→
    {codepoint = 1237, with = "ae"},    -- MA# ( ӕ → ae ) CYRILLIC SMALL LIGATURE A IE → LATIN SMALL LETTER A, LATIN SMALL LETTER E# →ае→
    {codepoint = 1248, with = "3"},     -- MA# ( Ӡ → 3 ) CYRILLIC CAPITAL LETTER ABKHASIAN DZE → DIGIT THREE# →Ʒ→
    {codepoint = 1281, with = "d"},     -- MA# ( ԁ → d ) CYRILLIC SMALL LETTER KOMI DE → LATIN SMALL LETTER D#
    {codepoint = 1292, with = "G"},     -- MA# ( Ԍ → G ) CYRILLIC CAPITAL LETTER KOMI SJE → LATIN CAPITAL LETTER G#
    {codepoint = 1307, with = "q"},     -- MA# ( ԛ → q ) CYRILLIC SMALL LETTER QA → LATIN SMALL LETTER Q#
    {codepoint = 1308, with = "W"},     -- MA# ( Ԝ → W ) CYRILLIC CAPITAL LETTER WE → LATIN CAPITAL LETTER W#
    {codepoint = 1309, with = "w"},     -- MA# ( ԝ → w ) CYRILLIC SMALL LETTER WE → LATIN SMALL LETTER W#
    {codepoint = 1357, with = "U"},     -- MA# ( Ս → U ) ARMENIAN CAPITAL LETTER SEH → LATIN CAPITAL LETTER U#
    {codepoint = 1359, with = "S"},     -- MA# ( Տ → S ) ARMENIAN CAPITAL LETTER TIWN → LATIN CAPITAL LETTER S#
    {codepoint = 1365, with = "O"},     -- MA# ( Օ → O ) ARMENIAN CAPITAL LETTER OH → LATIN CAPITAL LETTER O#
    {codepoint = 1370, with = "'"},     -- MA#* ( ՚ → ' ) ARMENIAN APOSTROPHE → APOSTROPHE# →’→
    {codepoint = 1373, with = "'"},     -- MA#* ( ՝ → ' ) ARMENIAN COMMA → APOSTROPHE# →ˋ→→｀→→‘→
    {codepoint = 1377, with = "w"},     -- MA# ( ա → w ) ARMENIAN SMALL LETTER AYB → LATIN SMALL LETTER W# →ɯ→
    {codepoint = 1379, with = "q"},     -- MA# ( գ → q ) ARMENIAN SMALL LETTER GIM → LATIN SMALL LETTER Q#
    {codepoint = 1382, with = "q"},     -- MA# ( զ → q ) ARMENIAN SMALL LETTER ZA → LATIN SMALL LETTER Q#
    {codepoint = 1392, with = "h"},     -- MA# ( հ → h ) ARMENIAN SMALL LETTER HO → LATIN SMALL LETTER H#
    {codepoint = 1400, with = "n"},     -- MA# ( ո → n ) ARMENIAN SMALL LETTER VO → LATIN SMALL LETTER N#
    {codepoint = 1404, with = "n"},     -- MA# ( ռ → n ) ARMENIAN SMALL LETTER RA → LATIN SMALL LETTER N#
    {codepoint = 1405, with = "u"},     -- MA# ( ս → u ) ARMENIAN SMALL LETTER SEH → LATIN SMALL LETTER U#
    {codepoint = 1409, with = "g"},     -- MA# ( ց → g ) ARMENIAN SMALL LETTER CO → LATIN SMALL LETTER G#
    {codepoint = 1412, with = "f"},     -- MA# ( ք → f ) ARMENIAN SMALL LETTER KEH → LATIN SMALL LETTER F#
    {codepoint = 1413, with = "o"},     -- MA# ( օ → o ) ARMENIAN SMALL LETTER OH → LATIN SMALL LETTER O#
    {codepoint = 1417, with = ":"},     -- MA#* ( ։ → : ) ARMENIAN FULL STOP → COLON#
    {codepoint = 1472, with = "l"},     -- MA#* ( ‎׀‎ → l ) HEBREW PUNCTUATION PASEQ → LATIN SMALL LETTER L# →|→
    {codepoint = 1475, with = ":"},     -- MA#* ( ‎׃‎ → : ) HEBREW PUNCTUATION SOF PASUQ → COLON#
    {codepoint = 1493, with = "l"},     -- MA# ( ‎ו‎ → l ) HEBREW LETTER VAV → LATIN SMALL LETTER L#
    {codepoint = 1496, with = "v"},     -- MA# ( ‎ט‎ → v ) HEBREW LETTER TET → LATIN SMALL LETTER V#
    {codepoint = 1497, with = "'"},     -- MA# ( ‎י‎ → ' ) HEBREW LETTER YOD → APOSTROPHE#
    {codepoint = 1503, with = "l"},     -- MA# ( ‎ן‎ → l ) HEBREW LETTER FINAL NUN → LATIN SMALL LETTER L#
    {codepoint = 1505, with = "o"},     -- MA# ( ‎ס‎ → o ) HEBREW LETTER SAMEKH → LATIN SMALL LETTER O#
    {codepoint = 1520, with = "ll"},    -- MA# ( ‎װ‎ → ll ) HEBREW LIGATURE YIDDISH DOUBLE VAV → LATIN SMALL LETTER L, LATIN SMALL LETTER L# →‎וו‎→
    {codepoint = 1521, with = "l'"},    -- MA# ( ‎ױ‎ → l' ) HEBREW LIGATURE YIDDISH VAV YOD → LATIN SMALL LETTER L, APOSTROPHE# →‎וי‎→
    {codepoint = 1522, with = "\""},    -- MA# ( ‎ײ‎ → '' ) HEBREW LIGATURE YIDDISH DOUBLE YOD → APOSTROPHE, APOSTROPHE# →‎יי‎→# Converted to a quote.
    {codepoint = 1523, with = "'"},     -- MA#* ( ‎׳‎ → ' ) HEBREW PUNCTUATION GERESH → APOSTROPHE#
    {codepoint = 1524, with = "\""},    -- MA#* ( ‎״‎ → '' ) HEBREW PUNCTUATION GERSHAYIM → APOSTROPHE, APOSTROPHE# →with = "→# Converted to a quote.
    {codepoint = 1549, with = ","},     -- MA#* ( ‎؍‎ → , ) ARABIC DATE SEPARATOR → COMMA# →‎٫‎→
    {codepoint = 1575, with = "l"},     -- MA# ( ‎ا‎ → l ) ARABIC LETTER ALEF → LATIN SMALL LETTER L# →1→
    {codepoint = 1607, with = "o"},     -- MA# ( ‎ه‎ → o ) ARABIC LETTER HEH → LATIN SMALL LETTER O#
    {codepoint = 1632, with = "."},     -- MA# ( ‎٠‎ → . ) ARABIC-INDIC DIGIT ZERO → FULL STOP#
    {codepoint = 1633, with = "l"},     -- MA# ( ‎١‎ → l ) ARABIC-INDIC DIGIT ONE → LATIN SMALL LETTER L# →1→
    {codepoint = 1637, with = "o"},     -- MA# ( ‎٥‎ → o ) ARABIC-INDIC DIGIT FIVE → LATIN SMALL LETTER O#
    {codepoint = 1639, with = "V"},     -- MA# ( ‎٧‎ → V ) ARABIC-INDIC DIGIT SEVEN → LATIN CAPITAL LETTER V#
    {codepoint = 1643, with = ","},     -- MA#* ( ‎٫‎ → , ) ARABIC DECIMAL SEPARATOR → COMMA#
    {codepoint = 1645, with = "*"},     -- MA#* ( ‎٭‎ → * ) ARABIC FIVE POINTED STAR → ASTERISK#
    {codepoint = 1726, with = "o"},     -- MA# ( ‎ھ‎ → o ) ARABIC LETTER HEH DOACHASHMEE → LATIN SMALL LETTER O# →‎ه‎→
    {codepoint = 1729, with = "o"},     -- MA# ( ‎ہ‎ → o ) ARABIC LETTER HEH GOAL → LATIN SMALL LETTER O# →‎ه‎→
    {codepoint = 1748, with = "-"},     -- MA#* ( ‎۔‎ → - ) ARABIC FULL STOP → HYPHEN-MINUS# →‐→
    {codepoint = 1749, with = "o"},     -- MA# ( ‎ە‎ → o ) ARABIC LETTER AE → LATIN SMALL LETTER O# →‎ه‎→
    {codepoint = 1776, with = "."},     -- MA# ( ۰ → . ) EXTENDED ARABIC-INDIC DIGIT ZERO → FULL STOP# →‎٠‎→
    {codepoint = 1777, with = "l"},     -- MA# ( ۱ → l ) EXTENDED ARABIC-INDIC DIGIT ONE → LATIN SMALL LETTER L# →1→
    {codepoint = 1781, with = "o"},     -- MA# ( ۵ → o ) EXTENDED ARABIC-INDIC DIGIT FIVE → LATIN SMALL LETTER O# →‎٥‎→
    {codepoint = 1783, with = "V"},     -- MA# ( ۷ → V ) EXTENDED ARABIC-INDIC DIGIT SEVEN → LATIN CAPITAL LETTER V# →‎٧‎→
    {codepoint = 1793, with = "."},     -- MA#* ( ‎܁‎ → . ) SYRIAC SUPRALINEAR FULL STOP → FULL STOP#
    {codepoint = 1794, with = "."},     -- MA#* ( ‎܂‎ → . ) SYRIAC SUBLINEAR FULL STOP → FULL STOP#
    {codepoint = 1795, with = ":"},     -- MA#* ( ‎܃‎ → : ) SYRIAC SUPRALINEAR COLON → COLON#
    {codepoint = 1796, with = ":"},     -- MA#* ( ‎܄‎ → : ) SYRIAC SUBLINEAR COLON → COLON#
    {codepoint = 1984, with = "O"},     -- MA# ( ‎߀‎ → O ) NKO DIGIT ZERO → LATIN CAPITAL LETTER O# →0→
    {codepoint = 1994, with = "l"},     -- MA# ( ‎ߊ‎ → l ) NKO LETTER A → LATIN SMALL LETTER L# →∣→→ǀ→
    {codepoint = 2036, with = "'"},     -- MA# ( ‎ߴ‎ → ' ) NKO HIGH TONE APOSTROPHE → APOSTROPHE# →’→
    {codepoint = 2037, with = "'"},     -- MA# ( ‎ߵ‎ → ' ) NKO LOW TONE APOSTROPHE → APOSTROPHE# →‘→
    {codepoint = 2042, with = "_"},     -- MA# ( ‎ߺ‎ → _ ) NKO LAJANYALAN → LOW LINE#
    {codepoint = 2307, with = ":"},     -- MA# ( ः → : ) DEVANAGARI SIGN VISARGA → COLON#
    {codepoint = 2406, with = "o"},     -- MA# ( ० → o ) DEVANAGARI DIGIT ZERO → LATIN SMALL LETTER O#
    {codepoint = 2429, with = "?"},     -- MA# ( ॽ → ? ) DEVANAGARI LETTER GLOTTAL STOP → QUESTION MARK#
    {codepoint = 2534, with = "O"},     -- MA# ( ০ → O ) BENGALI DIGIT ZERO → LATIN CAPITAL LETTER O# →0→
    {codepoint = 2538, with = "8"},     -- MA# ( ৪ → 8 ) BENGALI DIGIT FOUR → DIGIT EIGHT#
    {codepoint = 2541, with = "9"},     -- MA# ( ৭ → 9 ) BENGALI DIGIT SEVEN → DIGIT NINE#
    {codepoint = 2662, with = "o"},     -- MA# ( ੦ → o ) GURMUKHI DIGIT ZERO → LATIN SMALL LETTER O#
    {codepoint = 2663, with = "9"},     -- MA# ( ੧ → 9 ) GURMUKHI DIGIT ONE → DIGIT NINE#
    {codepoint = 2666, with = "8"},     -- MA# ( ੪ → 8 ) GURMUKHI DIGIT FOUR → DIGIT EIGHT#
    {codepoint = 2691, with = ":"},     -- MA# ( ઃ → : ) GUJARATI SIGN VISARGA → COLON#
    {codepoint = 2790, with = "o"},     -- MA# ( ૦ → o ) GUJARATI DIGIT ZERO → LATIN SMALL LETTER O#
    {codepoint = 2819, with = "8"},     -- MA# ( ଃ → 8 ) ORIYA SIGN VISARGA → DIGIT EIGHT#
    {codepoint = 2848, with = "O"},     -- MA# ( ଠ → O ) ORIYA LETTER TTHA → LATIN CAPITAL LETTER O# →୦→→0→
    {codepoint = 2918, with = "O"},     -- MA# ( ୦ → O ) ORIYA DIGIT ZERO → LATIN CAPITAL LETTER O# →0→
    {codepoint = 2920, with = "9"},     -- MA# ( ୨ → 9 ) ORIYA DIGIT TWO → DIGIT NINE#
    {codepoint = 3046, with = "o"},     -- MA# ( ௦ → o ) TAMIL DIGIT ZERO → LATIN SMALL LETTER O#
    {codepoint = 3074, with = "o"},     -- MA# ( ం → o ) TELUGU SIGN ANUSVARA → LATIN SMALL LETTER O#
    {codepoint = 3174, with = "o"},     -- MA# ( ౦ → o ) TELUGU DIGIT ZERO → LATIN SMALL LETTER O#
    {codepoint = 3202, with = "o"},     -- MA# ( ಂ → o ) KANNADA SIGN ANUSVARA → LATIN SMALL LETTER O#
    {codepoint = 3302, with = "o"},     -- MA# ( ೦ → o ) KANNADA DIGIT ZERO → LATIN SMALL LETTER O# →౦→
    {codepoint = 3330, with = "o"},     -- MA# ( ം → o ) MALAYALAM SIGN ANUSVARA → LATIN SMALL LETTER O#
    {codepoint = 3360, with = "o"},     -- MA# ( ഠ → o ) MALAYALAM LETTER TTHA → LATIN SMALL LETTER O#
    {codepoint = 3430, with = "o"},     -- MA# ( ൦ → o ) MALAYALAM DIGIT ZERO → LATIN SMALL LETTER O#
    {codepoint = 3437, with = "9"},     -- MA# ( ൭ → 9 ) MALAYALAM DIGIT SEVEN → DIGIT NINE#
    {codepoint = 3458, with = "o"},     -- MA# ( ං → o ) SINHALA SIGN ANUSVARAYA → LATIN SMALL LETTER O#
    {codepoint = 3664, with = "o"},     -- MA# ( ๐ → o ) THAI DIGIT ZERO → LATIN SMALL LETTER O#
    {codepoint = 3792, with = "o"},     -- MA# ( ໐ → o ) LAO DIGIT ZERO → LATIN SMALL LETTER O#
    {codepoint = 4125, with = "o"},     -- MA# ( ဝ → o ) MYANMAR LETTER WA → LATIN SMALL LETTER O#
    {codepoint = 4160, with = "o"},     -- MA# ( ၀ → o ) MYANMAR DIGIT ZERO → LATIN SMALL LETTER O#
    {codepoint = 4327, with = "y"},     -- MA# ( ყ → y ) GEORGIAN LETTER QAR → LATIN SMALL LETTER Y#
    {codepoint = 4351, with = "o"},     -- MA# ( ჿ → o ) GEORGIAN LETTER LABIAL SIGN → LATIN SMALL LETTER O#
    {codepoint = 4608, with = "U"},     -- MA# ( ሀ → U ) ETHIOPIC SYLLABLE HA → LATIN CAPITAL LETTER U# →Ս→
    {codepoint = 4816, with = "O"},     -- MA# ( ዐ → O ) ETHIOPIC SYLLABLE PHARYNGEAL A → LATIN CAPITAL LETTER O# →Օ→
    {codepoint = 5024, with = "D"},     -- MA# ( Ꭰ → D ) CHEROKEE LETTER A → LATIN CAPITAL LETTER D#
    {codepoint = 5025, with = "R"},     -- MA# ( Ꭱ → R ) CHEROKEE LETTER E → LATIN CAPITAL LETTER R#
    {codepoint = 5026, with = "T"},     -- MA# ( Ꭲ → T ) CHEROKEE LETTER I → LATIN CAPITAL LETTER T#
    {codepoint = 5028, with = "O'"},    -- MA# ( Ꭴ → O' ) CHEROKEE LETTER U → LATIN CAPITAL LETTER O, APOSTROPHE# →Ơ→→Oʼ→
    {codepoint = 5029, with = "i"},     -- MA# ( Ꭵ → i ) CHEROKEE LETTER V → LATIN SMALL LETTER I#
    {codepoint = 5033, with = "Y"},     -- MA# ( Ꭹ → Y ) CHEROKEE LETTER GI → LATIN CAPITAL LETTER Y#
    {codepoint = 5034, with = "A"},     -- MA# ( Ꭺ → A ) CHEROKEE LETTER GO → LATIN CAPITAL LETTER A#
    {codepoint = 5035, with = "J"},     -- MA# ( Ꭻ → J ) CHEROKEE LETTER GU → LATIN CAPITAL LETTER J#
    {codepoint = 5036, with = "E"},     -- MA# ( Ꭼ → E ) CHEROKEE LETTER GV → LATIN CAPITAL LETTER E#
    {codepoint = 5038, with = "?"},     -- MA# ( Ꭾ → ? ) CHEROKEE LETTER HE → QUESTION MARK# →Ɂ→→ʔ→
    {codepoint = 5043, with = "W"},     -- MA# ( Ꮃ → W ) CHEROKEE LETTER LA → LATIN CAPITAL LETTER W#
    {codepoint = 5047, with = "M"},     -- MA# ( Ꮇ → M ) CHEROKEE LETTER LU → LATIN CAPITAL LETTER M#
    {codepoint = 5051, with = "H"},     -- MA# ( Ꮋ → H ) CHEROKEE LETTER MI → LATIN CAPITAL LETTER H#
    {codepoint = 5053, with = "Y"},     -- MA# ( Ꮍ → Y ) CHEROKEE LETTER MU → LATIN CAPITAL LETTER Y# →Ꭹ→
    {codepoint = 5056, with = "G"},     -- MA# ( Ꮐ → G ) CHEROKEE LETTER NAH → LATIN CAPITAL LETTER G#
    {codepoint = 5058, with = "h"},     -- MA# ( Ꮒ → h ) CHEROKEE LETTER NI → LATIN SMALL LETTER H#
    {codepoint = 5059, with = "Z"},     -- MA# ( Ꮓ → Z ) CHEROKEE LETTER NO → LATIN CAPITAL LETTER Z#
    {codepoint = 5070, with = "4"},     -- MA# ( Ꮞ → 4 ) CHEROKEE LETTER SE → DIGIT FOUR#
    {codepoint = 5071, with = "b"},     -- MA# ( Ꮟ → b ) CHEROKEE LETTER SI → LATIN SMALL LETTER B#
    {codepoint = 5074, with = "R"},     -- MA# ( Ꮢ → R ) CHEROKEE LETTER SV → LATIN CAPITAL LETTER R#
    {codepoint = 5076, with = "W"},     -- MA# ( Ꮤ → W ) CHEROKEE LETTER TA → LATIN CAPITAL LETTER W#
    {codepoint = 5077, with = "S"},     -- MA# ( Ꮥ → S ) CHEROKEE LETTER DE → LATIN CAPITAL LETTER S#
    {codepoint = 5081, with = "V"},     -- MA# ( Ꮩ → V ) CHEROKEE LETTER DO → LATIN CAPITAL LETTER V#
    {codepoint = 5082, with = "S"},     -- MA# ( Ꮪ → S ) CHEROKEE LETTER DU → LATIN CAPITAL LETTER S#
    {codepoint = 5086, with = "L"},     -- MA# ( Ꮮ → L ) CHEROKEE LETTER TLE → LATIN CAPITAL LETTER L#
    {codepoint = 5087, with = "C"},     -- MA# ( Ꮯ → C ) CHEROKEE LETTER TLI → LATIN CAPITAL LETTER C#
    {codepoint = 5090, with = "P"},     -- MA# ( Ꮲ → P ) CHEROKEE LETTER TLV → LATIN CAPITAL LETTER P#
    {codepoint = 5094, with = "K"},     -- MA# ( Ꮶ → K ) CHEROKEE LETTER TSO → LATIN CAPITAL LETTER K#
    {codepoint = 5095, with = "d"},     -- MA# ( Ꮷ → d ) CHEROKEE LETTER TSU → LATIN SMALL LETTER D#
    {codepoint = 5102, with = "6"},     -- MA# ( Ꮾ → 6 ) CHEROKEE LETTER WV → DIGIT SIX#
    {codepoint = 5107, with = "G"},     -- MA# ( Ᏻ → G ) CHEROKEE LETTER YU → LATIN CAPITAL LETTER G#
    {codepoint = 5108, with = "B"},     -- MA# ( Ᏼ → B ) CHEROKEE LETTER YV → LATIN CAPITAL LETTER B#
    {codepoint = 5120, with = "="},     -- MA#* ( ᐀ → = ) CANADIAN SYLLABICS HYPHEN → EQUALS SIGN#
    {codepoint = 5167, with = "V"},     -- MA# ( ᐯ → V ) CANADIAN SYLLABICS PE → LATIN CAPITAL LETTER V#
    {codepoint = 5171, with = ">"},     -- MA# ( ᐳ → > ) CANADIAN SYLLABICS PO → GREATER-THAN SIGN#
    {codepoint = 5176, with = "<"},     -- MA# ( ᐸ → < ) CANADIAN SYLLABICS PA → LESS-THAN SIGN#
    {codepoint = 5194, with = "'"},     -- MA# ( ᑊ → ' ) CANADIAN SYLLABICS WEST-CREE P → APOSTROPHE# →ˈ→
    {codepoint = 5196, with = "U"},     -- MA# ( ᑌ → U ) CANADIAN SYLLABICS TE → LATIN CAPITAL LETTER U#
    {codepoint = 5223, with = "U'"},    -- MA# ( ᑧ → U' ) CANADIAN SYLLABICS TTE → LATIN CAPITAL LETTER U, APOSTROPHE# →ᑌᑊ→→ᑌ'→
    {codepoint = 5229, with = "P"},     -- MA# ( ᑭ → P ) CANADIAN SYLLABICS KI → LATIN CAPITAL LETTER P#
    {codepoint = 5231, with = "d"},     -- MA# ( ᑯ → d ) CANADIAN SYLLABICS KO → LATIN SMALL LETTER D#
    {codepoint = 5254, with = "P'"},    -- MA# ( ᒆ → P' ) CANADIAN SYLLABICS SOUTH-SLAVEY KIH → LATIN CAPITAL LETTER P, APOSTROPHE# →ᑭᑊ→
    {codepoint = 5255, with = "d'"},    -- MA# ( ᒇ → d' ) CANADIAN SYLLABICS SOUTH-SLAVEY KOH → LATIN SMALL LETTER D, APOSTROPHE# →ᑯᑊ→
    {codepoint = 5261, with = "J"},     -- MA# ( ᒍ → J ) CANADIAN SYLLABICS CO → LATIN CAPITAL LETTER J#
    {codepoint = 5290, with = "L"},     -- MA# ( ᒪ → L ) CANADIAN SYLLABICS MA → LATIN CAPITAL LETTER L#
    {codepoint = 5311, with = "2"},     -- MA# ( ᒿ → 2 ) CANADIAN SYLLABICS SAYISI M → DIGIT TWO#
    {codepoint = 5441, with = "x"},     -- MA# ( ᕁ → x ) CANADIAN SYLLABICS SAYISI YI → LATIN SMALL LETTER X# →᙮→
    {codepoint = 5500, with = "H"},     -- MA# ( ᕼ → H ) CANADIAN SYLLABICS NUNAVUT H → LATIN CAPITAL LETTER H#
    {codepoint = 5501, with = "x"},     -- MA# ( ᕽ → x ) CANADIAN SYLLABICS HK → LATIN SMALL LETTER X# →ᕁ→→᙮→
    {codepoint = 5511, with = "R"},     -- MA# ( ᖇ → R ) CANADIAN SYLLABICS TLHI → LATIN CAPITAL LETTER R#
    {codepoint = 5551, with = "b"},     -- MA# ( ᖯ → b ) CANADIAN SYLLABICS AIVILIK B → LATIN SMALL LETTER B#
    {codepoint = 5556, with = "F"},     -- MA# ( ᖴ → F ) CANADIAN SYLLABICS BLACKFOOT WE → LATIN CAPITAL LETTER F#
    {codepoint = 5573, with = "A"},     -- MA# ( ᗅ → A ) CANADIAN SYLLABICS CARRIER GHO → LATIN CAPITAL LETTER A#
    {codepoint = 5598, with = "D"},     -- MA# ( ᗞ → D ) CANADIAN SYLLABICS CARRIER THE → LATIN CAPITAL LETTER D#
    {codepoint = 5610, with = "D"},     -- MA# ( ᗪ → D ) CANADIAN SYLLABICS CARRIER PE → LATIN CAPITAL LETTER D# →ᗞ→
    {codepoint = 5616, with = "M"},     -- MA# ( ᗰ → M ) CANADIAN SYLLABICS CARRIER GO → LATIN CAPITAL LETTER M#
    {codepoint = 5623, with = "B"},     -- MA# ( ᗷ → B ) CANADIAN SYLLABICS CARRIER KHE → LATIN CAPITAL LETTER B#
    {codepoint = 5741, with = "X"},     -- MA#* ( ᙭ → X ) CANADIAN SYLLABICS CHI SIGN → LATIN CAPITAL LETTER X#
    {codepoint = 5742, with = "x"},     -- MA#* ( ᙮ → x ) CANADIAN SYLLABICS FULL STOP → LATIN SMALL LETTER X#
    {codepoint = 5760, with = " "},     -- MA#* (   →   ) OGHAM SPACE MARK → SPACE#
    {codepoint = 5810, with = "<"},     -- MA# ( ᚲ → < ) RUNIC LETTER KAUNA → LESS-THAN SIGN#
    {codepoint = 5815, with = "X"},     -- MA# ( ᚷ → X ) RUNIC LETTER GEBO GYFU G → LATIN CAPITAL LETTER X#
    {codepoint = 5825, with = "l"},     -- MA# ( ᛁ → l ) RUNIC LETTER ISAZ IS ISS I → LATIN SMALL LETTER L# →I→
    {codepoint = 5836, with = "'"},     -- MA# ( ᛌ → ' ) RUNIC LETTER SHORT-TWIG-SOL S → APOSTROPHE#
    {codepoint = 5845, with = "K"},     -- MA# ( ᛕ → K ) RUNIC LETTER OPEN-P → LATIN CAPITAL LETTER K#
    {codepoint = 5846, with = "M"},     -- MA# ( ᛖ → M ) RUNIC LETTER EHWAZ EH E → LATIN CAPITAL LETTER M#
    {codepoint = 5868, with = ":"},     -- MA#* ( ᛬ → : ) RUNIC MULTIPLE PUNCTUATION → COLON#
    {codepoint = 5869, with = "+"},     -- MA#* ( ᛭ → + ) RUNIC CROSS PUNCTUATION → PLUS SIGN#
    {codepoint = 5941, with = "/"},     -- MA#* ( ᜵ → / ) PHILIPPINE SINGLE PUNCTUATION → SOLIDUS#
    {codepoint = 6147, with = ":"},     -- MA#* ( ᠃ → : ) MONGOLIAN FULL STOP → COLON#
    {codepoint = 6153, with = ":"},     -- MA#* ( ᠉ → : ) MONGOLIAN MANCHU FULL STOP → COLON#
    {codepoint = 7379, with = "\""},    -- MA#* ( ᳓ → '' ) VEDIC SIGN NIHSHVASA → APOSTROPHE, APOSTROPHE# →″→→with = "→# Converted to a quote.
    {codepoint = 7428, with = "c"},     -- MA# ( ᴄ → c ) LATIN LETTER SMALL CAPITAL C → LATIN SMALL LETTER C#
    {codepoint = 7439, with = "o"},     -- MA# ( ᴏ → o ) LATIN LETTER SMALL CAPITAL O → LATIN SMALL LETTER O#
    {codepoint = 7441, with = "o"},     -- MA# ( ᴑ → o ) LATIN SMALL LETTER SIDEWAYS O → LATIN SMALL LETTER O#
    {codepoint = 7452, with = "u"},     -- MA# ( ᴜ → u ) LATIN LETTER SMALL CAPITAL U → LATIN SMALL LETTER U#
    {codepoint = 7456, with = "v"},     -- MA# ( ᴠ → v ) LATIN LETTER SMALL CAPITAL V → LATIN SMALL LETTER V#
    {codepoint = 7457, with = "w"},     -- MA# ( ᴡ → w ) LATIN LETTER SMALL CAPITAL W → LATIN SMALL LETTER W#
    {codepoint = 7458, with = "z"},     -- MA# ( ᴢ → z ) LATIN LETTER SMALL CAPITAL Z → LATIN SMALL LETTER Z#
    {codepoint = 7462, with = "r"},     -- MA# ( ᴦ → r ) GREEK LETTER SMALL CAPITAL GAMMA → LATIN SMALL LETTER R# →г→
    {codepoint = 7531, with = "ue"},    -- MA# ( ᵫ → ue ) LATIN SMALL LETTER UE → LATIN SMALL LETTER U, LATIN SMALL LETTER E#
    {codepoint = 7555, with = "g"},     -- MA# ( ᶃ → g ) LATIN SMALL LETTER G WITH PALATAL HOOK → LATIN SMALL LETTER G#
    {codepoint = 7564, with = "y"},     -- MA# ( ᶌ → y ) LATIN SMALL LETTER V WITH PALATAL HOOK → LATIN SMALL LETTER Y#
    {codepoint = 7837, with = "f"},     -- MA# ( ẝ → f ) LATIN SMALL LETTER LONG S WITH HIGH STROKE → LATIN SMALL LETTER F#
    {codepoint = 7935, with = "y"},     -- MA# ( ỿ → y ) LATIN SMALL LETTER Y WITH LOOP → LATIN SMALL LETTER Y#
    {codepoint = 8125, with = "'"},     -- MA#* ( ᾽ → ' ) GREEK KORONIS → APOSTROPHE# →’→
    {codepoint = 8126, with = "i"},     -- MA# ( ι → i ) GREEK PROSGEGRAMMENI → LATIN SMALL LETTER I# →ι→
    {codepoint = 8127, with = "'"},     -- MA#* ( ᾿ → ' ) GREEK PSILI → APOSTROPHE# →’→
    {codepoint = 8128, with = "~"},     -- MA#* ( ῀ → ~ ) GREEK PERISPOMENI → TILDE# →˜→
    {codepoint = 8175, with = "'"},     -- MA#* ( ` → ' ) GREEK VARIA → APOSTROPHE# →ˋ→→｀→→‘→
    {codepoint = 8189, with = "'"},     -- MA#* ( ´ → ' ) GREEK OXIA → APOSTROPHE# →´→→΄→→ʹ→
    {codepoint = 8190, with = "'"},     -- MA#* ( ῾ → ' ) GREEK DASIA → APOSTROPHE# →‛→→′→
    {codepoint = 8192, with = " "},     -- MA#* (   →   ) EN QUAD → SPACE#
    {codepoint = 8193, with = " "},     -- MA#* (   →   ) EM QUAD → SPACE#
    {codepoint = 8194, with = " "},     -- MA#* (   →   ) EN SPACE → SPACE#
    {codepoint = 8195, with = " "},     -- MA#* (   →   ) EM SPACE → SPACE#
    {codepoint = 8196, with = " "},     -- MA#* (   →   ) THREE-PER-EM SPACE → SPACE#
    {codepoint = 8197, with = " "},     -- MA#* (   →   ) FOUR-PER-EM SPACE → SPACE#
    {codepoint = 8198, with = " "},     -- MA#* (   →   ) SIX-PER-EM SPACE → SPACE#
    {codepoint = 8199, with = " "},     -- MA#* (   →   ) FIGURE SPACE → SPACE#
    {codepoint = 8200, with = " "},     -- MA#* (   →   ) PUNCTUATION SPACE → SPACE#
    {codepoint = 8201, with = " "},     -- MA#* (   →   ) THIN SPACE → SPACE#
    {codepoint = 8202, with = " "},     -- MA#* (   →   ) HAIR SPACE → SPACE#
    {codepoint = 8208, with = "-"},     -- MA#* ( ‐ → - ) HYPHEN → HYPHEN-MINUS#
    {codepoint = 8209, with = "-"},     -- MA#* ( ‑ → - ) NON-BREAKING HYPHEN → HYPHEN-MINUS#
    {codepoint = 8210, with = "-"},     -- MA#* ( ‒ → - ) FIGURE DASH → HYPHEN-MINUS#
    {codepoint = 8211, with = "-"},     -- MA#* ( – → - ) EN DASH → HYPHEN-MINUS#
    {codepoint = 8214, with = "ll"},    -- MA#* ( ‖ → ll ) DOUBLE VERTICAL LINE → LATIN SMALL LETTER L, LATIN SMALL LETTER L# →∥→→||→
    {codepoint = 8216, with = "'"},     -- MA#* ( ‘ → ' ) LEFT SINGLE QUOTATION MARK → APOSTROPHE#
    {codepoint = 8217, with = "'"},     -- MA#* ( ’ → ' ) RIGHT SINGLE QUOTATION MARK → APOSTROPHE#
    {codepoint = 8218, with = ","},     -- MA#* ( ‚ → , ) SINGLE LOW-9 QUOTATION MARK → COMMA#
    {codepoint = 8219, with = "'"},     -- MA#* ( ‛ → ' ) SINGLE HIGH-REVERSED-9 QUOTATION MARK → APOSTROPHE# →′→
    {codepoint = 8220, with = "\""},    -- MA#* ( “ → '' ) LEFT DOUBLE QUOTATION MARK → APOSTROPHE, APOSTROPHE# →with = "→# Converted to a quote.
    {codepoint = 8221, with = "\""},    -- MA#* ( ” → '' ) RIGHT DOUBLE QUOTATION MARK → APOSTROPHE, APOSTROPHE# →with = "→# Converted to a quote.
    {codepoint = 8223, with = "\""},    -- MA#* ( ‟ → '' ) DOUBLE HIGH-REVERSED-9 QUOTATION MARK → APOSTROPHE, APOSTROPHE# →“→→with = "→# Converted to a quote.
    {codepoint = 8228, with = "."},     -- MA#* ( ․ → . ) ONE DOT LEADER → FULL STOP#
    {codepoint = 8229, with = ".."},    -- MA#* ( ‥ → .. ) TWO DOT LEADER → FULL STOP, FULL STOP#
    {codepoint = 8230, with = "..."},   -- MA#* ( … → ... ) HORIZONTAL ELLIPSIS → FULL STOP, FULL STOP, FULL STOP#
    {codepoint = 8232, with = " "},     -- MA#* (  →   ) LINE SEPARATOR → SPACE#
    {codepoint = 8233, with = " "},     -- MA#* (  →   ) PARAGRAPH SEPARATOR → SPACE#
    {codepoint = 8239, with = " "},     -- MA#* (   →   ) NARROW NO-BREAK SPACE → SPACE#
    {codepoint = 8242, with = "'"},     -- MA#* ( ′ → ' ) PRIME → APOSTROPHE#
    {codepoint = 8243, with = "\""},    -- MA#* ( ″ → '' ) DOUBLE PRIME → APOSTROPHE, APOSTROPHE# →with = "→# Converted to a quote.
    {codepoint = 8244, with = "'''"},   -- MA#* ( ‴ → ''' ) TRIPLE PRIME → APOSTROPHE, APOSTROPHE, APOSTROPHE# →′′′→
    {codepoint = 8245, with = "'"},     -- MA#* ( ‵ → ' ) REVERSED PRIME → APOSTROPHE# →ʽ→→‘→
    {codepoint = 8246, with = "\""},    -- MA#* ( ‶ → '' ) REVERSED DOUBLE PRIME → APOSTROPHE, APOSTROPHE# →‵‵→# Converted to a quote.
    {codepoint = 8247, with = "'''"},   -- MA#* ( ‷ → ''' ) REVERSED TRIPLE PRIME → APOSTROPHE, APOSTROPHE, APOSTROPHE# →‵‵‵→
    {codepoint = 8249, with = "<"},     -- MA#* ( ‹ → < ) SINGLE LEFT-POINTING ANGLE QUOTATION MARK → LESS-THAN SIGN#
    {codepoint = 8250, with = ">"},     -- MA#* ( › → > ) SINGLE RIGHT-POINTING ANGLE QUOTATION MARK → GREATER-THAN SIGN#
    {codepoint = 8252, with = "!!"},    -- MA#* ( ‼ → !! ) DOUBLE EXCLAMATION MARK → EXCLAMATION MARK, EXCLAMATION MARK#
    {codepoint = 8257, with = "/"},     -- MA#* ( ⁁ → / ) CARET INSERTION POINT → SOLIDUS#
    {codepoint = 8259, with = "-"},     -- MA#* ( ⁃ → - ) HYPHEN BULLET → HYPHEN-MINUS# →‐→
    {codepoint = 8260, with = "/"},     -- MA#* ( ⁄ → / ) FRACTION SLASH → SOLIDUS#
    {codepoint = 8263, with = "??"},    -- MA#* ( ⁇ → ?? ) DOUBLE QUESTION MARK → QUESTION MARK, QUESTION MARK#
    {codepoint = 8264, with = "?!"},    -- MA#* ( ⁈ → ?! ) QUESTION EXCLAMATION MARK → QUESTION MARK, EXCLAMATION MARK#
    {codepoint = 8265, with = "!?"},    -- MA#* ( ⁉ → !? ) EXCLAMATION QUESTION MARK → EXCLAMATION MARK, QUESTION MARK#
    {codepoint = 8270, with = "*"},     -- MA#* ( ⁎ → * ) LOW ASTERISK → ASTERISK#
    {codepoint = 8275, with = "~"},     -- MA#* ( ⁓ → ~ ) SWUNG DASH → TILDE#
    {codepoint = 8279, with = "''''"},  -- MA#* ( ⁗ → '''' ) QUADRUPLE PRIME → APOSTROPHE, APOSTROPHE, APOSTROPHE, APOSTROPHE# →′′′′→
    {codepoint = 8282, with = ":"},     -- MA#* ( ⁚ → : ) TWO DOT PUNCTUATION → COLON#
    {codepoint = 8287, with = " "},     -- MA#* (   →   ) MEDIUM MATHEMATICAL SPACE → SPACE#
    {codepoint = 8360, with = "Rs"},    -- MA#* ( ₨ → Rs ) RUPEE SIGN → LATIN CAPITAL LETTER R, LATIN SMALL LETTER S#
    {codepoint = 8374, with = "lt"},    -- MA#* ( ₶ → lt ) LIVRE TOURNOIS SIGN → LATIN SMALL LETTER L, LATIN SMALL LETTER T#
    {codepoint = 8448, with = "a/c"},   -- MA#* ( ℀ → a/c ) ACCOUNT OF → LATIN SMALL LETTER A, SOLIDUS, LATIN SMALL LETTER C#
    {codepoint = 8449, with = "a/s"},   -- MA#* ( ℁ → a/s ) ADDRESSED TO THE SUBJECT → LATIN SMALL LETTER A, SOLIDUS, LATIN SMALL LETTER S#
    {codepoint = 8450, with = "C"},     -- MA# ( ℂ → C ) DOUBLE-STRUCK CAPITAL C → LATIN CAPITAL LETTER C#
    {codepoint = 8453, with = "c/o"},   -- MA#* ( ℅ → c/o ) CARE OF → LATIN SMALL LETTER C, SOLIDUS, LATIN SMALL LETTER O#
    {codepoint = 8454, with = "c/u"},   -- MA#* ( ℆ → c/u ) CADA UNA → LATIN SMALL LETTER C, SOLIDUS, LATIN SMALL LETTER U#
    {codepoint = 8458, with = "g"},     -- MA# ( ℊ → g ) SCRIPT SMALL G → LATIN SMALL LETTER G#
    {codepoint = 8459, with = "H"},     -- MA# ( ℋ → H ) SCRIPT CAPITAL H → LATIN CAPITAL LETTER H#
    {codepoint = 8460, with = "H"},     -- MA# ( ℌ → H ) BLACK-LETTER CAPITAL H → LATIN CAPITAL LETTER H#
    {codepoint = 8461, with = "H"},     -- MA# ( ℍ → H ) DOUBLE-STRUCK CAPITAL H → LATIN CAPITAL LETTER H#
    {codepoint = 8462, with = "h"},     -- MA# ( ℎ → h ) PLANCK CONSTANT → LATIN SMALL LETTER H#
    {codepoint = 8464, with = "l"},     -- MA# ( ℐ → l ) SCRIPT CAPITAL I → LATIN SMALL LETTER L# →I→
    {codepoint = 8465, with = "l"},     -- MA# ( ℑ → l ) BLACK-LETTER CAPITAL I → LATIN SMALL LETTER L# →I→
    {codepoint = 8466, with = "L"},     -- MA# ( ℒ → L ) SCRIPT CAPITAL L → LATIN CAPITAL LETTER L#
    {codepoint = 8467, with = "l"},     -- MA# ( ℓ → l ) SCRIPT SMALL L → LATIN SMALL LETTER L#
    {codepoint = 8469, with = "N"},     -- MA# ( ℕ → N ) DOUBLE-STRUCK CAPITAL N → LATIN CAPITAL LETTER N#
    {codepoint = 8470, with = "No"},    -- MA#* ( № → No ) NUMERO SIGN → LATIN CAPITAL LETTER N, LATIN SMALL LETTER O#
    {codepoint = 8473, with = "P"},     -- MA# ( ℙ → P ) DOUBLE-STRUCK CAPITAL P → LATIN CAPITAL LETTER P#
    {codepoint = 8474, with = "Q"},     -- MA# ( ℚ → Q ) DOUBLE-STRUCK CAPITAL Q → LATIN CAPITAL LETTER Q#
    {codepoint = 8475, with = "R"},     -- MA# ( ℛ → R ) SCRIPT CAPITAL R → LATIN CAPITAL LETTER R#
    {codepoint = 8476, with = "R"},     -- MA# ( ℜ → R ) BLACK-LETTER CAPITAL R → LATIN CAPITAL LETTER R#
    {codepoint = 8477, with = "R"},     -- MA# ( ℝ → R ) DOUBLE-STRUCK CAPITAL R → LATIN CAPITAL LETTER R#
    {codepoint = 8481, with = "TEL"},   -- MA#* ( ℡ → TEL ) TELEPHONE SIGN → LATIN CAPITAL LETTER T, LATIN CAPITAL LETTER E, LATIN CAPITAL LETTER L#
    {codepoint = 8484, with = "Z"},     -- MA# ( ℤ → Z ) DOUBLE-STRUCK CAPITAL Z → LATIN CAPITAL LETTER Z#
    {codepoint = 8488, with = "Z"},     -- MA# ( ℨ → Z ) BLACK-LETTER CAPITAL Z → LATIN CAPITAL LETTER Z#
    {codepoint = 8490, with = "K"},     -- MA# ( K → K ) KELVIN SIGN → LATIN CAPITAL LETTER K#
    {codepoint = 8492, with = "B"},     -- MA# ( ℬ → B ) SCRIPT CAPITAL B → LATIN CAPITAL LETTER B#
    {codepoint = 8493, with = "C"},     -- MA# ( ℭ → C ) BLACK-LETTER CAPITAL C → LATIN CAPITAL LETTER C#
    {codepoint = 8494, with = "e"},     -- MA# ( ℮ → e ) ESTIMATED SYMBOL → LATIN SMALL LETTER E#
    {codepoint = 8495, with = "e"},     -- MA# ( ℯ → e ) SCRIPT SMALL E → LATIN SMALL LETTER E#
    {codepoint = 8496, with = "E"},     -- MA# ( ℰ → E ) SCRIPT CAPITAL E → LATIN CAPITAL LETTER E#
    {codepoint = 8497, with = "F"},     -- MA# ( ℱ → F ) SCRIPT CAPITAL F → LATIN CAPITAL LETTER F#
    {codepoint = 8499, with = "M"},     -- MA# ( ℳ → M ) SCRIPT CAPITAL M → LATIN CAPITAL LETTER M#
    {codepoint = 8500, with = "o"},     -- MA# ( ℴ → o ) SCRIPT SMALL O → LATIN SMALL LETTER O#
    {codepoint = 8505, with = "i"},     -- MA# ( ℹ → i ) INFORMATION SOURCE → LATIN SMALL LETTER I#
    {codepoint = 8507, with = "FAX"},   -- MA#* ( ℻ → FAX ) FACSIMILE SIGN → LATIN CAPITAL LETTER F, LATIN CAPITAL LETTER A, LATIN CAPITAL LETTER X#
    {codepoint = 8509, with = "y"},     -- MA# ( ℽ → y ) DOUBLE-STRUCK SMALL GAMMA → LATIN SMALL LETTER Y# →γ→
    {codepoint = 8517, with = "D"},     -- MA# ( ⅅ → D ) DOUBLE-STRUCK ITALIC CAPITAL D → LATIN CAPITAL LETTER D#
    {codepoint = 8518, with = "d"},     -- MA# ( ⅆ → d ) DOUBLE-STRUCK ITALIC SMALL D → LATIN SMALL LETTER D#
    {codepoint = 8519, with = "e"},     -- MA# ( ⅇ → e ) DOUBLE-STRUCK ITALIC SMALL E → LATIN SMALL LETTER E#
    {codepoint = 8520, with = "i"},     -- MA# ( ⅈ → i ) DOUBLE-STRUCK ITALIC SMALL I → LATIN SMALL LETTER I#
    {codepoint = 8521, with = "j"},     -- MA# ( ⅉ → j ) DOUBLE-STRUCK ITALIC SMALL J → LATIN SMALL LETTER J#
    {codepoint = 8544, with = "l"},     -- MA# ( Ⅰ → l ) ROMAN NUMERAL ONE → LATIN SMALL LETTER L# →Ӏ→
    {codepoint = 8545, with = "ll"},    -- MA# ( Ⅱ → ll ) ROMAN NUMERAL TWO → LATIN SMALL LETTER L, LATIN SMALL LETTER L# →II→
    {codepoint = 8546, with = "lll"},   -- MA# ( Ⅲ → lll ) ROMAN NUMERAL THREE → LATIN SMALL LETTER L, LATIN SMALL LETTER L, LATIN SMALL LETTER L# →III→
    {codepoint = 8547, with = "lV"},    -- MA# ( Ⅳ → lV ) ROMAN NUMERAL FOUR → LATIN SMALL LETTER L, LATIN CAPITAL LETTER V# →IV→
    {codepoint = 8548, with = "V"},     -- MA# ( Ⅴ → V ) ROMAN NUMERAL FIVE → LATIN CAPITAL LETTER V#
    {codepoint = 8549, with = "Vl"},    -- MA# ( Ⅵ → Vl ) ROMAN NUMERAL SIX → LATIN CAPITAL LETTER V, LATIN SMALL LETTER L# →VI→
    {codepoint = 8550, with = "Vll"},   -- MA# ( Ⅶ → Vll ) ROMAN NUMERAL SEVEN → LATIN CAPITAL LETTER V, LATIN SMALL LETTER L, LATIN SMALL LETTER L# →VII→
    {codepoint = 8551, with = "Vlll"},  -- MA# ( Ⅷ → Vlll ) ROMAN NUMERAL EIGHT → LATIN CAPITAL LETTER V, LATIN SMALL LETTER L, LATIN SMALL LETTER L, LATIN SMALL LETTER L# →VIII→
    {codepoint = 8552, with = "lX"},    -- MA# ( Ⅸ → lX ) ROMAN NUMERAL NINE → LATIN SMALL LETTER L, LATIN CAPITAL LETTER X# →IX→
    {codepoint = 8553, with = "X"},     -- MA# ( Ⅹ → X ) ROMAN NUMERAL TEN → LATIN CAPITAL LETTER X#
    {codepoint = 8554, with = "Xl"},    -- MA# ( Ⅺ → Xl ) ROMAN NUMERAL ELEVEN → LATIN CAPITAL LETTER X, LATIN SMALL LETTER L# →XI→
    {codepoint = 8555, with = "Xll"},   -- MA# ( Ⅻ → Xll ) ROMAN NUMERAL TWELVE → LATIN CAPITAL LETTER X, LATIN SMALL LETTER L, LATIN SMALL LETTER L# →XII→
    {codepoint = 8556, with = "L"},     -- MA# ( Ⅼ → L ) ROMAN NUMERAL FIFTY → LATIN CAPITAL LETTER L#
    {codepoint = 8557, with = "C"},     -- MA# ( Ⅽ → C ) ROMAN NUMERAL ONE HUNDRED → LATIN CAPITAL LETTER C#
    {codepoint = 8558, with = "D"},     -- MA# ( Ⅾ → D ) ROMAN NUMERAL FIVE HUNDRED → LATIN CAPITAL LETTER D#
    {codepoint = 8559, with = "M"},     -- MA# ( Ⅿ → M ) ROMAN NUMERAL ONE THOUSAND → LATIN CAPITAL LETTER M#
    {codepoint = 8560, with = "i"},     -- MA# ( ⅰ → i ) SMALL ROMAN NUMERAL ONE → LATIN SMALL LETTER I#
    {codepoint = 8561, with = "ii"},    -- MA# ( ⅱ → ii ) SMALL ROMAN NUMERAL TWO → LATIN SMALL LETTER I, LATIN SMALL LETTER I#
    {codepoint = 8562, with = "iii"},   -- MA# ( ⅲ → iii ) SMALL ROMAN NUMERAL THREE → LATIN SMALL LETTER I, LATIN SMALL LETTER I, LATIN SMALL LETTER I#
    {codepoint = 8563, with = "iv"},    -- MA# ( ⅳ → iv ) SMALL ROMAN NUMERAL FOUR → LATIN SMALL LETTER I, LATIN SMALL LETTER V#
    {codepoint = 8564, with = "v"},     -- MA# ( ⅴ → v ) SMALL ROMAN NUMERAL FIVE → LATIN SMALL LETTER V#
    {codepoint = 8565, with = "vi"},    -- MA# ( ⅵ → vi ) SMALL ROMAN NUMERAL SIX → LATIN SMALL LETTER V, LATIN SMALL LETTER I#
    {codepoint = 8566, with = "vii"},   -- MA# ( ⅶ → vii ) SMALL ROMAN NUMERAL SEVEN → LATIN SMALL LETTER V, LATIN SMALL LETTER I, LATIN SMALL LETTER I#
    {codepoint = 8567, with = "viii"},  -- MA# ( ⅷ → viii ) SMALL ROMAN NUMERAL EIGHT → LATIN SMALL LETTER V, LATIN SMALL LETTER I, LATIN SMALL LETTER I, LATIN SMALL LETTER I#
    {codepoint = 8568, with = "ix"},    -- MA# ( ⅸ → ix ) SMALL ROMAN NUMERAL NINE → LATIN SMALL LETTER I, LATIN SMALL LETTER X#
    {codepoint = 8569, with = "x"},     -- MA# ( ⅹ → x ) SMALL ROMAN NUMERAL TEN → LATIN SMALL LETTER X#
    {codepoint = 8570, with = "xi"},    -- MA# ( ⅺ → xi ) SMALL ROMAN NUMERAL ELEVEN → LATIN SMALL LETTER X, LATIN SMALL LETTER I#
    {codepoint = 8571, with = "xii"},   -- MA# ( ⅻ → xii ) SMALL ROMAN NUMERAL TWELVE → LATIN SMALL LETTER X, LATIN SMALL LETTER I, LATIN SMALL LETTER I#
    {codepoint = 8572, with = "l"},     -- MA# ( ⅼ → l ) SMALL ROMAN NUMERAL FIFTY → LATIN SMALL LETTER L#
    {codepoint = 8573, with = "c"},     -- MA# ( ⅽ → c ) SMALL ROMAN NUMERAL ONE HUNDRED → LATIN SMALL LETTER C#
    {codepoint = 8574, with = "d"},     -- MA# ( ⅾ → d ) SMALL ROMAN NUMERAL FIVE HUNDRED → LATIN SMALL LETTER D#
    {codepoint = 8575, with = "rn"},    -- MA# ( ⅿ → rn ) SMALL ROMAN NUMERAL ONE THOUSAND → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 8722, with = "-"},     -- MA#* ( − → - ) MINUS SIGN → HYPHEN-MINUS#
    {codepoint = 8725, with = "/"},     -- MA#* ( ∕ → / ) DIVISION SLASH → SOLIDUS#
    {codepoint = 8726, with = "\\"},    -- MA#* ( ∖ → \ ) SET MINUS → REVERSE SOLIDUS#
    {codepoint = 8727, with = "*"},     -- MA#* ( ∗ → * ) ASTERISK OPERATOR → ASTERISK#
    {codepoint = 8734, with = "oo"},    -- MA#* ( ∞ → oo ) INFINITY → LATIN SMALL LETTER O, LATIN SMALL LETTER O# →ꝏ→
    {codepoint = 8739, with = "l"},     -- MA#* ( ∣ → l ) DIVIDES → LATIN SMALL LETTER L# →ǀ→
    {codepoint = 8741, with = "ll"},    -- MA#* ( ∥ → ll ) PARALLEL TO → LATIN SMALL LETTER L, LATIN SMALL LETTER L# →||→
    {codepoint = 8744, with = "v"},     -- MA#* ( ∨ → v ) LOGICAL OR → LATIN SMALL LETTER V#
    {codepoint = 8746, with = "U"},     -- MA#* ( ∪ → U ) UNION → LATIN CAPITAL LETTER U# →ᑌ→
    {codepoint = 8758, with = ":"},     -- MA#* ( ∶ → : ) RATIO → COLON#
    {codepoint = 8764, with = "~"},     -- MA#* ( ∼ → ~ ) TILDE OPERATOR → TILDE#
    {codepoint = 8810, with = "<<"},    -- MA#* ( ≪ → << ) MUCH LESS-THAN → LESS-THAN SIGN, LESS-THAN SIGN#
    {codepoint = 8811, with = ">>"},    -- MA#* ( ≫ → >> ) MUCH GREATER-THAN → GREATER-THAN SIGN, GREATER-THAN SIGN#
    {codepoint = 8868, with = "T"},     -- MA#* ( ⊤ → T ) DOWN TACK → LATIN CAPITAL LETTER T#
    {codepoint = 8897, with = "v"},     -- MA#* ( ⋁ → v ) N-ARY LOGICAL OR → LATIN SMALL LETTER V# →∨→
    {codepoint = 8899, with = "U"},     -- MA#* ( ⋃ → U ) N-ARY UNION → LATIN CAPITAL LETTER U# →∪→→ᑌ→
    {codepoint = 8920, with = "<<<"},   -- MA#* ( ⋘ → <<< ) VERY MUCH LESS-THAN → LESS-THAN SIGN, LESS-THAN SIGN, LESS-THAN SIGN#
    {codepoint = 8921, with = ">>>"},   -- MA#* ( ⋙ → >>> ) VERY MUCH GREATER-THAN → GREATER-THAN SIGN, GREATER-THAN SIGN, GREATER-THAN SIGN#
    {codepoint = 8959, with = "E"},     -- MA#* ( ⋿ → E ) Z NOTATION BAG MEMBERSHIP → LATIN CAPITAL LETTER E#
    {codepoint = 9075, with = "i"},     -- MA#* ( ⍳ → i ) APL FUNCTIONAL SYMBOL IOTA → LATIN SMALL LETTER I# →ι→
    {codepoint = 9076, with = "p"},     -- MA#* ( ⍴ → p ) APL FUNCTIONAL SYMBOL RHO → LATIN SMALL LETTER P# →ρ→
    {codepoint = 9082, with = "a"},     -- MA#* ( ⍺ → a ) APL FUNCTIONAL SYMBOL ALPHA → LATIN SMALL LETTER A# →α→
    {codepoint = 9213, with = "l"},     -- MA#* ( ⏽ → l ) POWER ON SYMBOL → LATIN SMALL LETTER L# →I→
    {codepoint = 9290, with = "\\\\"},  -- MA#* ( ⑊ → \\ ) OCR DOUBLE BACKSLASH → REVERSE SOLIDUS, REVERSE SOLIDUS#
    {codepoint = 9332, with = "(l)"},   -- MA#* ( ⑴ → (l) ) PARENTHESIZED DIGIT ONE → LEFT PARENTHESIS, LATIN SMALL LETTER L, RIGHT PARENTHESIS# →(1)→
    {codepoint = 9333, with = "(2)"},   -- MA#* ( ⑵ → (2) ) PARENTHESIZED DIGIT TWO → LEFT PARENTHESIS, DIGIT TWO, RIGHT PARENTHESIS#
    {codepoint = 9334, with = "(3)"},   -- MA#* ( ⑶ → (3) ) PARENTHESIZED DIGIT THREE → LEFT PARENTHESIS, DIGIT THREE, RIGHT PARENTHESIS#
    {codepoint = 9335, with = "(4)"},   -- MA#* ( ⑷ → (4) ) PARENTHESIZED DIGIT FOUR → LEFT PARENTHESIS, DIGIT FOUR, RIGHT PARENTHESIS#
    {codepoint = 9336, with = "(5)"},   -- MA#* ( ⑸ → (5) ) PARENTHESIZED DIGIT FIVE → LEFT PARENTHESIS, DIGIT FIVE, RIGHT PARENTHESIS#
    {codepoint = 9337, with = "(6)"},   -- MA#* ( ⑹ → (6) ) PARENTHESIZED DIGIT SIX → LEFT PARENTHESIS, DIGIT SIX, RIGHT PARENTHESIS#
    {codepoint = 9338, with = "(7)"},   -- MA#* ( ⑺ → (7) ) PARENTHESIZED DIGIT SEVEN → LEFT PARENTHESIS, DIGIT SEVEN, RIGHT PARENTHESIS#
    {codepoint = 9339, with = "(8)"},   -- MA#* ( ⑻ → (8) ) PARENTHESIZED DIGIT EIGHT → LEFT PARENTHESIS, DIGIT EIGHT, RIGHT PARENTHESIS#
    {codepoint = 9340, with = "(9)"},   -- MA#* ( ⑼ → (9) ) PARENTHESIZED DIGIT NINE → LEFT PARENTHESIS, DIGIT NINE, RIGHT PARENTHESIS#
    {codepoint = 9341, with = "(lO)"},  -- MA#* ( ⑽ → (lO) ) PARENTHESIZED NUMBER TEN → LEFT PARENTHESIS, LATIN SMALL LETTER L, LATIN CAPITAL LETTER O, RIGHT PARENTHESIS# →(10)→
    {codepoint = 9342, with = "(ll)"},  -- MA#* ( ⑾ → (ll) ) PARENTHESIZED NUMBER ELEVEN → LEFT PARENTHESIS, LATIN SMALL LETTER L, LATIN SMALL LETTER L, RIGHT PARENTHESIS# →(11)→
    {codepoint = 9343, with = "(l2)"},  -- MA#* ( ⑿ → (l2) ) PARENTHESIZED NUMBER TWELVE → LEFT PARENTHESIS, LATIN SMALL LETTER L, DIGIT TWO, RIGHT PARENTHESIS# →(12)→
    {codepoint = 9344, with = "(l3)"},  -- MA#* ( ⒀ → (l3) ) PARENTHESIZED NUMBER THIRTEEN → LEFT PARENTHESIS, LATIN SMALL LETTER L, DIGIT THREE, RIGHT PARENTHESIS# →(13)→
    {codepoint = 9345, with = "(l4)"},  -- MA#* ( ⒁ → (l4) ) PARENTHESIZED NUMBER FOURTEEN → LEFT PARENTHESIS, LATIN SMALL LETTER L, DIGIT FOUR, RIGHT PARENTHESIS# →(14)→
    {codepoint = 9346, with = "(l5)"},  -- MA#* ( ⒂ → (l5) ) PARENTHESIZED NUMBER FIFTEEN → LEFT PARENTHESIS, LATIN SMALL LETTER L, DIGIT FIVE, RIGHT PARENTHESIS# →(15)→
    {codepoint = 9347, with = "(l6)"},  -- MA#* ( ⒃ → (l6) ) PARENTHESIZED NUMBER SIXTEEN → LEFT PARENTHESIS, LATIN SMALL LETTER L, DIGIT SIX, RIGHT PARENTHESIS# →(16)→
    {codepoint = 9348, with = "(l7)"},  -- MA#* ( ⒄ → (l7) ) PARENTHESIZED NUMBER SEVENTEEN → LEFT PARENTHESIS, LATIN SMALL LETTER L, DIGIT SEVEN, RIGHT PARENTHESIS# →(17)→
    {codepoint = 9349, with = "(l8)"},  -- MA#* ( ⒅ → (l8) ) PARENTHESIZED NUMBER EIGHTEEN → LEFT PARENTHESIS, LATIN SMALL LETTER L, DIGIT EIGHT, RIGHT PARENTHESIS# →(18)→
    {codepoint = 9350, with = "(l9)"},  -- MA#* ( ⒆ → (l9) ) PARENTHESIZED NUMBER NINETEEN → LEFT PARENTHESIS, LATIN SMALL LETTER L, DIGIT NINE, RIGHT PARENTHESIS# →(19)→
    {codepoint = 9351, with = "(2O)"},  -- MA#* ( ⒇ → (2O) ) PARENTHESIZED NUMBER TWENTY → LEFT PARENTHESIS, DIGIT TWO, LATIN CAPITAL LETTER O, RIGHT PARENTHESIS# →(20)→
    {codepoint = 9352, with = "l."},    -- MA#* ( ⒈ → l. ) DIGIT ONE FULL STOP → LATIN SMALL LETTER L, FULL STOP# →1.→
    {codepoint = 9353, with = "2."},    -- MA#* ( ⒉ → 2. ) DIGIT TWO FULL STOP → DIGIT TWO, FULL STOP#
    {codepoint = 9354, with = "3."},    -- MA#* ( ⒊ → 3. ) DIGIT THREE FULL STOP → DIGIT THREE, FULL STOP#
    {codepoint = 9355, with = "4."},    -- MA#* ( ⒋ → 4. ) DIGIT FOUR FULL STOP → DIGIT FOUR, FULL STOP#
    {codepoint = 9356, with = "5."},    -- MA#* ( ⒌ → 5. ) DIGIT FIVE FULL STOP → DIGIT FIVE, FULL STOP#
    {codepoint = 9357, with = "6."},    -- MA#* ( ⒍ → 6. ) DIGIT SIX FULL STOP → DIGIT SIX, FULL STOP#
    {codepoint = 9358, with = "7."},    -- MA#* ( ⒎ → 7. ) DIGIT SEVEN FULL STOP → DIGIT SEVEN, FULL STOP#
    {codepoint = 9359, with = "8."},    -- MA#* ( ⒏ → 8. ) DIGIT EIGHT FULL STOP → DIGIT EIGHT, FULL STOP#
    {codepoint = 9360, with = "9."},    -- MA#* ( ⒐ → 9. ) DIGIT NINE FULL STOP → DIGIT NINE, FULL STOP#
    {codepoint = 9361, with = "lO."},   -- MA#* ( ⒑ → lO. ) NUMBER TEN FULL STOP → LATIN SMALL LETTER L, LATIN CAPITAL LETTER O, FULL STOP# →10.→
    {codepoint = 9362, with = "ll."},   -- MA#* ( ⒒ → ll. ) NUMBER ELEVEN FULL STOP → LATIN SMALL LETTER L, LATIN SMALL LETTER L, FULL STOP# →11.→
    {codepoint = 9363, with = "l2."},   -- MA#* ( ⒓ → l2. ) NUMBER TWELVE FULL STOP → LATIN SMALL LETTER L, DIGIT TWO, FULL STOP# →12.→
    {codepoint = 9364, with = "l3."},   -- MA#* ( ⒔ → l3. ) NUMBER THIRTEEN FULL STOP → LATIN SMALL LETTER L, DIGIT THREE, FULL STOP# →13.→
    {codepoint = 9365, with = "l4."},   -- MA#* ( ⒕ → l4. ) NUMBER FOURTEEN FULL STOP → LATIN SMALL LETTER L, DIGIT FOUR, FULL STOP# →14.→
    {codepoint = 9366, with = "l5."},   -- MA#* ( ⒖ → l5. ) NUMBER FIFTEEN FULL STOP → LATIN SMALL LETTER L, DIGIT FIVE, FULL STOP# →15.→
    {codepoint = 9367, with = "l6."},   -- MA#* ( ⒗ → l6. ) NUMBER SIXTEEN FULL STOP → LATIN SMALL LETTER L, DIGIT SIX, FULL STOP# →16.→
    {codepoint = 9368, with = "l7."},   -- MA#* ( ⒘ → l7. ) NUMBER SEVENTEEN FULL STOP → LATIN SMALL LETTER L, DIGIT SEVEN, FULL STOP# →17.→
    {codepoint = 9369, with = "l8."},   -- MA#* ( ⒙ → l8. ) NUMBER EIGHTEEN FULL STOP → LATIN SMALL LETTER L, DIGIT EIGHT, FULL STOP# →18.→
    {codepoint = 9370, with = "l9."},   -- MA#* ( ⒚ → l9. ) NUMBER NINETEEN FULL STOP → LATIN SMALL LETTER L, DIGIT NINE, FULL STOP# →19.→
    {codepoint = 9371, with = "2O."},   -- MA#* ( ⒛ → 2O. ) NUMBER TWENTY FULL STOP → DIGIT TWO, LATIN CAPITAL LETTER O, FULL STOP# →20.→
    {codepoint = 9372, with = "(a)"},   -- MA#* ( ⒜ → (a) ) PARENTHESIZED LATIN SMALL LETTER A → LEFT PARENTHESIS, LATIN SMALL LETTER A, RIGHT PARENTHESIS#
    {codepoint = 9373, with = "(b)"},   -- MA#* ( ⒝ → (b) ) PARENTHESIZED LATIN SMALL LETTER B → LEFT PARENTHESIS, LATIN SMALL LETTER B, RIGHT PARENTHESIS#
    {codepoint = 9374, with = "(c)"},   -- MA#* ( ⒞ → (c) ) PARENTHESIZED LATIN SMALL LETTER C → LEFT PARENTHESIS, LATIN SMALL LETTER C, RIGHT PARENTHESIS#
    {codepoint = 9375, with = "(d)"},   -- MA#* ( ⒟ → (d) ) PARENTHESIZED LATIN SMALL LETTER D → LEFT PARENTHESIS, LATIN SMALL LETTER D, RIGHT PARENTHESIS#
    {codepoint = 9376, with = "(e)"},   -- MA#* ( ⒠ → (e) ) PARENTHESIZED LATIN SMALL LETTER E → LEFT PARENTHESIS, LATIN SMALL LETTER E, RIGHT PARENTHESIS#
    {codepoint = 9377, with = "(f)"},   -- MA#* ( ⒡ → (f) ) PARENTHESIZED LATIN SMALL LETTER F → LEFT PARENTHESIS, LATIN SMALL LETTER F, RIGHT PARENTHESIS#
    {codepoint = 9378, with = "(g)"},   -- MA#* ( ⒢ → (g) ) PARENTHESIZED LATIN SMALL LETTER G → LEFT PARENTHESIS, LATIN SMALL LETTER G, RIGHT PARENTHESIS#
    {codepoint = 9379, with = "(h)"},   -- MA#* ( ⒣ → (h) ) PARENTHESIZED LATIN SMALL LETTER H → LEFT PARENTHESIS, LATIN SMALL LETTER H, RIGHT PARENTHESIS#
    {codepoint = 9380, with = "(i)"},   -- MA#* ( ⒤ → (i) ) PARENTHESIZED LATIN SMALL LETTER I → LEFT PARENTHESIS, LATIN SMALL LETTER I, RIGHT PARENTHESIS#
    {codepoint = 9381, with = "(j)"},   -- MA#* ( ⒥ → (j) ) PARENTHESIZED LATIN SMALL LETTER J → LEFT PARENTHESIS, LATIN SMALL LETTER J, RIGHT PARENTHESIS#
    {codepoint = 9382, with = "(k)"},   -- MA#* ( ⒦ → (k) ) PARENTHESIZED LATIN SMALL LETTER K → LEFT PARENTHESIS, LATIN SMALL LETTER K, RIGHT PARENTHESIS#
    {codepoint = 9383, with = "(l)"},   -- MA#* ( ⒧ → (l) ) PARENTHESIZED LATIN SMALL LETTER L → LEFT PARENTHESIS, LATIN SMALL LETTER L, RIGHT PARENTHESIS#
    {codepoint = 9384, with = "(rn)"},  -- MA#* ( ⒨ → (rn) ) PARENTHESIZED LATIN SMALL LETTER M → LEFT PARENTHESIS, LATIN SMALL LETTER R, LATIN SMALL LETTER N, RIGHT PARENTHESIS# →(m)→
    {codepoint = 9385, with = "(n)"},   -- MA#* ( ⒩ → (n) ) PARENTHESIZED LATIN SMALL LETTER N → LEFT PARENTHESIS, LATIN SMALL LETTER N, RIGHT PARENTHESIS#
    {codepoint = 9386, with = "(o)"},   -- MA#* ( ⒪ → (o) ) PARENTHESIZED LATIN SMALL LETTER O → LEFT PARENTHESIS, LATIN SMALL LETTER O, RIGHT PARENTHESIS#
    {codepoint = 9387, with = "(p)"},   -- MA#* ( ⒫ → (p) ) PARENTHESIZED LATIN SMALL LETTER P → LEFT PARENTHESIS, LATIN SMALL LETTER P, RIGHT PARENTHESIS#
    {codepoint = 9388, with = "(q)"},   -- MA#* ( ⒬ → (q) ) PARENTHESIZED LATIN SMALL LETTER Q → LEFT PARENTHESIS, LATIN SMALL LETTER Q, RIGHT PARENTHESIS#
    {codepoint = 9389, with = "(r)"},   -- MA#* ( ⒭ → (r) ) PARENTHESIZED LATIN SMALL LETTER R → LEFT PARENTHESIS, LATIN SMALL LETTER R, RIGHT PARENTHESIS#
    {codepoint = 9390, with = "(s)"},   -- MA#* ( ⒮ → (s) ) PARENTHESIZED LATIN SMALL LETTER S → LEFT PARENTHESIS, LATIN SMALL LETTER S, RIGHT PARENTHESIS#
    {codepoint = 9391, with = "(t)"},   -- MA#* ( ⒯ → (t) ) PARENTHESIZED LATIN SMALL LETTER T → LEFT PARENTHESIS, LATIN SMALL LETTER T, RIGHT PARENTHESIS#
    {codepoint = 9392, with = "(u)"},   -- MA#* ( ⒰ → (u) ) PARENTHESIZED LATIN SMALL LETTER U → LEFT PARENTHESIS, LATIN SMALL LETTER U, RIGHT PARENTHESIS#
    {codepoint = 9393, with = "(v)"},   -- MA#* ( ⒱ → (v) ) PARENTHESIZED LATIN SMALL LETTER V → LEFT PARENTHESIS, LATIN SMALL LETTER V, RIGHT PARENTHESIS#
    {codepoint = 9394, with = "(w)"},   -- MA#* ( ⒲ → (w) ) PARENTHESIZED LATIN SMALL LETTER W → LEFT PARENTHESIS, LATIN SMALL LETTER W, RIGHT PARENTHESIS#
    {codepoint = 9395, with = "(x)"},   -- MA#* ( ⒳ → (x) ) PARENTHESIZED LATIN SMALL LETTER X → LEFT PARENTHESIS, LATIN SMALL LETTER X, RIGHT PARENTHESIS#
    {codepoint = 9396, with = "(y)"},   -- MA#* ( ⒴ → (y) ) PARENTHESIZED LATIN SMALL LETTER Y → LEFT PARENTHESIS, LATIN SMALL LETTER Y, RIGHT PARENTHESIS#
    {codepoint = 9397, with = "(z)"},   -- MA#* ( ⒵ → (z) ) PARENTHESIZED LATIN SMALL LETTER Z → LEFT PARENTHESIS, LATIN SMALL LETTER Z, RIGHT PARENTHESIS#
    {codepoint = 9585, with = "/"},     -- MA#* ( ╱ → / ) BOX DRAWINGS LIGHT DIAGONAL UPPER RIGHT TO LOWER LEFT → SOLIDUS#
    {codepoint = 9587, with = "X"},     -- MA#* ( ╳ → X ) BOX DRAWINGS LIGHT DIAGONAL CROSS → LATIN CAPITAL LETTER X#
    {codepoint = 10088, with = "("},    -- MA#* ( ❨ → ( ) MEDIUM LEFT PARENTHESIS ORNAMENT → LEFT PARENTHESIS#
    {codepoint = 10089, with = ")"},    -- MA#* ( ❩ → ) ) MEDIUM RIGHT PARENTHESIS ORNAMENT → RIGHT PARENTHESIS#
    {codepoint = 10094, with = "<"},    -- MA#* ( ❮ → < ) HEAVY LEFT-POINTING ANGLE QUOTATION MARK ORNAMENT → LESS-THAN SIGN# →‹→
    {codepoint = 10095, with = ">"},    -- MA#* ( ❯ → > ) HEAVY RIGHT-POINTING ANGLE QUOTATION MARK ORNAMENT → GREATER-THAN SIGN# →›→
    {codepoint = 10098, with = "("},    -- MA#* ( ❲ → ( ) LIGHT LEFT TORTOISE SHELL BRACKET ORNAMENT → LEFT PARENTHESIS# →〔→
    {codepoint = 10099, with = ")"},    -- MA#* ( ❳ → ) ) LIGHT RIGHT TORTOISE SHELL BRACKET ORNAMENT → RIGHT PARENTHESIS# →〕→
    {codepoint = 10100, with = "{"},    -- MA#* ( ❴ → { ) MEDIUM LEFT CURLY BRACKET ORNAMENT → LEFT CURLY BRACKET#
    {codepoint = 10101, with = "}"},    -- MA#* ( ❵ → } ) MEDIUM RIGHT CURLY BRACKET ORNAMENT → RIGHT CURLY BRACKET#
    {codepoint = 10133, with = "+"},    -- MA#* ( ➕ → + ) HEAVY PLUS SIGN → PLUS SIGN#
    {codepoint = 10134, with = "-"},    -- MA#* ( ➖ → - ) HEAVY MINUS SIGN → HYPHEN-MINUS# →−→
    {codepoint = 10187, with = "/"},    -- MA#* ( ⟋ → / ) MATHEMATICAL RISING DIAGONAL → SOLIDUS#
    {codepoint = 10189, with = "\\"},   -- MA#* ( ⟍ → \ ) MATHEMATICAL FALLING DIAGONAL → REVERSE SOLIDUS#
    {codepoint = 10201, with = "T"},    -- MA#* ( ⟙ → T ) LARGE DOWN TACK → LATIN CAPITAL LETTER T#
    {codepoint = 10539, with = "x"},    -- MA#* ( ⤫ → x ) RISING DIAGONAL CROSSING FALLING DIAGONAL → LATIN SMALL LETTER X#
    {codepoint = 10540, with = "x"},    -- MA#* ( ⤬ → x ) FALLING DIAGONAL CROSSING RISING DIAGONAL → LATIN SMALL LETTER X#
    {codepoint = 10741, with = "\\"},   -- MA#* ( ⧵ → \ ) REVERSE SOLIDUS OPERATOR → REVERSE SOLIDUS#
    {codepoint = 10744, with = "/"},    -- MA#* ( ⧸ → / ) BIG SOLIDUS → SOLIDUS#
    {codepoint = 10745, with = "\\"},   -- MA#* ( ⧹ → \ ) BIG REVERSE SOLIDUS → REVERSE SOLIDUS#
    {codepoint = 10784, with = ">>"},   -- MA#* ( ⨠ → >> ) Z NOTATION SCHEMA PIPING → GREATER-THAN SIGN, GREATER-THAN SIGN# →≫→
    {codepoint = 10799, with = "x"},    -- MA#* ( ⨯ → x ) VECTOR OR CROSS PRODUCT → LATIN SMALL LETTER X# →×→
    {codepoint = 10868, with = "::="},  -- MA#* ( ⩴ → ::= ) DOUBLE COLON EQUAL → COLON, COLON, EQUALS SIGN#
    {codepoint = 10869, with = "=="},   -- MA#* ( ⩵ → == ) TWO CONSECUTIVE EQUALS SIGNS → EQUALS SIGN, EQUALS SIGN#
    {codepoint = 10870, with = "==="},  -- MA#* ( ⩶ → === ) THREE CONSECUTIVE EQUALS SIGNS → EQUALS SIGN, EQUALS SIGN, EQUALS SIGN#
    {codepoint = 10917, with = "><"},   -- MA#* ( ⪥ → >< ) GREATER-THAN BESIDE LESS-THAN → GREATER-THAN SIGN, LESS-THAN SIGN#
    {codepoint = 11003, with = "--/"},  -- MA#* ( ⫻ → --/ ) TRIPLE SOLIDUS BINARY RELATION → SOLIDUS, SOLIDUS, SOLIDUS#
    {codepoint = 11005, with = "--"},   -- MA#* ( ⫽ → -- ) DOUBLE SOLIDUS OPERATOR → SOLIDUS, SOLIDUS#
    {codepoint = 11397, with = "r"},    -- MA# ( ⲅ → r ) COPTIC SMALL LETTER GAMMA → LATIN SMALL LETTER R# →г→
    {codepoint = 11406, with = "H"},    -- MA# ( Ⲏ → H ) COPTIC CAPITAL LETTER HATE → LATIN CAPITAL LETTER H# →Η→
    {codepoint = 11410, with = "l"},    -- MA# ( Ⲓ → l ) COPTIC CAPITAL LETTER IAUDA → LATIN SMALL LETTER L# →Ӏ→
    {codepoint = 11412, with = "K"},    -- MA# ( Ⲕ → K ) COPTIC CAPITAL LETTER KAPA → LATIN CAPITAL LETTER K# →Κ→
    {codepoint = 11416, with = "M"},    -- MA# ( Ⲙ → M ) COPTIC CAPITAL LETTER MI → LATIN CAPITAL LETTER M#
    {codepoint = 11418, with = "N"},    -- MA# ( Ⲛ → N ) COPTIC CAPITAL LETTER NI → LATIN CAPITAL LETTER N#
    {codepoint = 11422, with = "O"},    -- MA# ( Ⲟ → O ) COPTIC CAPITAL LETTER O → LATIN CAPITAL LETTER O#
    {codepoint = 11423, with = "o"},    -- MA# ( ⲟ → o ) COPTIC SMALL LETTER O → LATIN SMALL LETTER O#
    {codepoint = 11426, with = "P"},    -- MA# ( Ⲣ → P ) COPTIC CAPITAL LETTER RO → LATIN CAPITAL LETTER P#
    {codepoint = 11427, with = "p"},    -- MA# ( ⲣ → p ) COPTIC SMALL LETTER RO → LATIN SMALL LETTER P# →ρ→
    {codepoint = 11428, with = "C"},    -- MA# ( Ⲥ → C ) COPTIC CAPITAL LETTER SIMA → LATIN CAPITAL LETTER C# →Ϲ→
    {codepoint = 11429, with = "c"},    -- MA# ( ⲥ → c ) COPTIC SMALL LETTER SIMA → LATIN SMALL LETTER C# →ϲ→
    {codepoint = 11430, with = "T"},    -- MA# ( Ⲧ → T ) COPTIC CAPITAL LETTER TAU → LATIN CAPITAL LETTER T#
    {codepoint = 11432, with = "Y"},    -- MA# ( Ⲩ → Y ) COPTIC CAPITAL LETTER UA → LATIN CAPITAL LETTER Y#
    {codepoint = 11436, with = "X"},    -- MA# ( Ⲭ → X ) COPTIC CAPITAL LETTER KHI → LATIN CAPITAL LETTER X# →Х→
    {codepoint = 11450, with = "-"},    -- MA# ( Ⲻ → - ) COPTIC CAPITAL LETTER DIALECT-P NI → HYPHEN-MINUS# →‒→
    {codepoint = 11462, with = "/"},    -- MA# ( Ⳇ → / ) COPTIC CAPITAL LETTER OLD COPTIC ESH → SOLIDUS#
    {codepoint = 11466, with = "9"},    -- MA# ( Ⳋ → 9 ) COPTIC CAPITAL LETTER DIALECT-P HORI → DIGIT NINE#
    {codepoint = 11468, with = "3"},    -- MA# ( Ⳍ → 3 ) COPTIC CAPITAL LETTER OLD COPTIC HORI → DIGIT THREE# →Ȝ→→Ʒ→
    {codepoint = 11472, with = "L"},    -- MA# ( Ⳑ → L ) COPTIC CAPITAL LETTER L-SHAPED HA → LATIN CAPITAL LETTER L#
    {codepoint = 11474, with = "6"},    -- MA# ( Ⳓ → 6 ) COPTIC CAPITAL LETTER OLD COPTIC HEI → DIGIT SIX#
    {codepoint = 11513, with = "\\\\"}, -- MA#* ( ⳹ → \\ ) COPTIC OLD NUBIAN FULL STOP → REVERSE SOLIDUS, REVERSE SOLIDUS#
    {codepoint = 11576, with = "V"},    -- MA# ( ⴸ → V ) TIFINAGH LETTER YADH → LATIN CAPITAL LETTER V#
    {codepoint = 11577, with = "E"},    -- MA# ( ⴹ → E ) TIFINAGH LETTER YADD → LATIN CAPITAL LETTER E#
    {codepoint = 11599, with = "l"},    -- MA# ( ⵏ → l ) TIFINAGH LETTER YAN → LATIN SMALL LETTER L# →Ӏ→
    {codepoint = 11601, with = "!"},    -- MA# ( ⵑ → ! ) TIFINAGH LETTER TUAREG YANG → EXCLAMATION MARK#
    {codepoint = 11604, with = "O"},    -- MA# ( ⵔ → O ) TIFINAGH LETTER YAR → LATIN CAPITAL LETTER O#
    {codepoint = 11605, with = "Q"},    -- MA# ( ⵕ → Q ) TIFINAGH LETTER YARR → LATIN CAPITAL LETTER Q#
    {codepoint = 11613, with = "X"},    -- MA# ( ⵝ → X ) TIFINAGH LETTER YATH → LATIN CAPITAL LETTER X#
    {codepoint = 11816, with = "(("},   -- MA#* ( ⸨ → (( ) LEFT DOUBLE PARENTHESIS → LEFT PARENTHESIS, LEFT PARENTHESIS#
    {codepoint = 11817, with = "))"},   -- MA#* ( ⸩ → )) ) RIGHT DOUBLE PARENTHESIS → RIGHT PARENTHESIS, RIGHT PARENTHESIS#
    {codepoint = 11840, with = "="},    -- MA#* ( ⹀ → = ) DOUBLE HYPHEN → EQUALS SIGN#
    {codepoint = 12034, with = "\\"},   -- MA#* ( ⼂ → \ ) KANGXI RADICAL DOT → REVERSE SOLIDUS#
    {codepoint = 12035, with = "/"},    -- MA#* ( ⼃ → / ) KANGXI RADICAL SLASH → SOLIDUS#
    {codepoint = 12291, with = "\""},   -- MA#* ( 〃 → '' ) DITTO MARK → APOSTROPHE, APOSTROPHE# →″→→with = "→# Converted to a quote.
    {codepoint = 12295, with = "O"},    -- MA# ( 〇 → O ) IDEOGRAPHIC NUMBER ZERO → LATIN CAPITAL LETTER O#
    {codepoint = 12308, with = "("},    -- MA#* ( 〔 → ( ) LEFT TORTOISE SHELL BRACKET → LEFT PARENTHESIS#
    {codepoint = 12309, with = ")"},    -- MA#* ( 〕 → ) ) RIGHT TORTOISE SHELL BRACKET → RIGHT PARENTHESIS#
    {codepoint = 12339, with = "/"},    -- MA# ( 〳 → / ) VERTICAL KANA REPEAT MARK UPPER HALF → SOLIDUS#
    {codepoint = 12448, with = "="},    -- MA#* ( ゠ → = ) KATAKANA-HIRAGANA DOUBLE HYPHEN → EQUALS SIGN#
    {codepoint = 12494, with = "/"},    -- MA# ( ノ → / ) KATAKANA LETTER NO → SOLIDUS# →⼃→
    {codepoint = 12755, with = "/"},    -- MA#* ( ㇓ → / ) CJK STROKE SP → SOLIDUS# →⼃→
    {codepoint = 12756, with = "\\"},   -- MA#* ( ㇔ → \ ) CJK STROKE D → REVERSE SOLIDUS# →⼂→
    {codepoint = 20022, with = "\\"},   -- MA# ( 丶 → \ ) CJK UNIFIED IDEOGRAPH-4E36 → REVERSE SOLIDUS# →⼂→
    {codepoint = 20031, with = "/"},    -- MA# ( 丿 → / ) CJK UNIFIED IDEOGRAPH-4E3F → SOLIDUS# →⼃→
    {codepoint = 42192, with = "B"},    -- MA# ( ꓐ → B ) LISU LETTER BA → LATIN CAPITAL LETTER B#
    {codepoint = 42193, with = "P"},    -- MA# ( ꓑ → P ) LISU LETTER PA → LATIN CAPITAL LETTER P#
    {codepoint = 42194, with = "d"},    -- MA# ( ꓒ → d ) LISU LETTER PHA → LATIN SMALL LETTER D#
    {codepoint = 42195, with = "D"},    -- MA# ( ꓓ → D ) LISU LETTER DA → LATIN CAPITAL LETTER D#
    {codepoint = 42196, with = "T"},    -- MA# ( ꓔ → T ) LISU LETTER TA → LATIN CAPITAL LETTER T#
    {codepoint = 42198, with = "G"},    -- MA# ( ꓖ → G ) LISU LETTER GA → LATIN CAPITAL LETTER G#
    {codepoint = 42199, with = "K"},    -- MA# ( ꓗ → K ) LISU LETTER KA → LATIN CAPITAL LETTER K#
    {codepoint = 42201, with = "J"},    -- MA# ( ꓙ → J ) LISU LETTER JA → LATIN CAPITAL LETTER J#
    {codepoint = 42202, with = "C"},    -- MA# ( ꓚ → C ) LISU LETTER CA → LATIN CAPITAL LETTER C#
    {codepoint = 42204, with = "Z"},    -- MA# ( ꓜ → Z ) LISU LETTER DZA → LATIN CAPITAL LETTER Z#
    {codepoint = 42205, with = "F"},    -- MA# ( ꓝ → F ) LISU LETTER TSA → LATIN CAPITAL LETTER F#
    {codepoint = 42207, with = "M"},    -- MA# ( ꓟ → M ) LISU LETTER MA → LATIN CAPITAL LETTER M#
    {codepoint = 42208, with = "N"},    -- MA# ( ꓠ → N ) LISU LETTER NA → LATIN CAPITAL LETTER N#
    {codepoint = 42209, with = "L"},    -- MA# ( ꓡ → L ) LISU LETTER LA → LATIN CAPITAL LETTER L#
    {codepoint = 42210, with = "S"},    -- MA# ( ꓢ → S ) LISU LETTER SA → LATIN CAPITAL LETTER S#
    {codepoint = 42211, with = "R"},    -- MA# ( ꓣ → R ) LISU LETTER ZHA → LATIN CAPITAL LETTER R#
    {codepoint = 42214, with = "V"},    -- MA# ( ꓦ → V ) LISU LETTER HA → LATIN CAPITAL LETTER V#
    {codepoint = 42215, with = "H"},    -- MA# ( ꓧ → H ) LISU LETTER XA → LATIN CAPITAL LETTER H#
    {codepoint = 42218, with = "W"},    -- MA# ( ꓪ → W ) LISU LETTER WA → LATIN CAPITAL LETTER W#
    {codepoint = 42219, with = "X"},    -- MA# ( ꓫ → X ) LISU LETTER SHA → LATIN CAPITAL LETTER X#
    {codepoint = 42220, with = "Y"},    -- MA# ( ꓬ → Y ) LISU LETTER YA → LATIN CAPITAL LETTER Y#
    {codepoint = 42222, with = "A"},    -- MA# ( ꓮ → A ) LISU LETTER A → LATIN CAPITAL LETTER A#
    {codepoint = 42224, with = "E"},    -- MA# ( ꓰ → E ) LISU LETTER E → LATIN CAPITAL LETTER E#
    {codepoint = 42226, with = "l"},    -- MA# ( ꓲ → l ) LISU LETTER I → LATIN SMALL LETTER L# →I→
    {codepoint = 42227, with = "O"},    -- MA# ( ꓳ → O ) LISU LETTER O → LATIN CAPITAL LETTER O#
    {codepoint = 42228, with = "U"},    -- MA# ( ꓴ → U ) LISU LETTER U → LATIN CAPITAL LETTER U#
    {codepoint = 42232, with = "."},    -- MA# ( ꓸ → . ) LISU LETTER TONE MYA TI → FULL STOP#
    {codepoint = 42233, with = ","},    -- MA# ( ꓹ → , ) LISU LETTER TONE NA PO → COMMA#
    {codepoint = 42234, with = ".."},   -- MA# ( ꓺ → .. ) LISU LETTER TONE MYA CYA → FULL STOP, FULL STOP#
    {codepoint = 42235, with = ".,"},   -- MA# ( ꓻ → ., ) LISU LETTER TONE MYA BO → FULL STOP, COMMA#
    {codepoint = 42237, with = ":"},    -- MA# ( ꓽ → : ) LISU LETTER TONE MYA JEU → COLON#
    {codepoint = 42238, with = "-."},   -- MA#* ( ꓾ → -. ) LISU PUNCTUATION COMMA → HYPHEN-MINUS, FULL STOP#
    {codepoint = 42239, with = "="},    -- MA#* ( ꓿ → = ) LISU PUNCTUATION FULL STOP → EQUALS SIGN#
    {codepoint = 42510, with = "."},    -- MA#* ( ꘎ → . ) VAI FULL STOP → FULL STOP#
    {codepoint = 42564, with = "2"},    -- MA# ( Ꙅ → 2 ) CYRILLIC CAPITAL LETTER REVERSED DZE → DIGIT TWO# →Ƨ→
    {codepoint = 42567, with = "i"},    -- MA# ( ꙇ → i ) CYRILLIC SMALL LETTER IOTA → LATIN SMALL LETTER I# →ι→
    {codepoint = 42648, with = "OO"},   -- MA# ( Ꚙ → OO ) CYRILLIC CAPITAL LETTER DOUBLE O → LATIN CAPITAL LETTER O, LATIN CAPITAL LETTER O#
    {codepoint = 42649, with = "oo"},   -- MA# ( ꚙ → oo ) CYRILLIC SMALL LETTER DOUBLE O → LATIN SMALL LETTER O, LATIN SMALL LETTER O#
    {codepoint = 42719, with = "V"},    -- MA# ( ꛟ → V ) BAMUM LETTER KO → LATIN CAPITAL LETTER V#
    {codepoint = 42731, with = "?"},    -- MA# ( ꛫ → ? ) BAMUM LETTER NTUU → QUESTION MARK# →ʔ→
    {codepoint = 42735, with = "2"},    -- MA# ( ꛯ → 2 ) BAMUM LETTER KOGHOM → DIGIT TWO# →Ƨ→
    {codepoint = 42792, with = "T3"},   -- MA# ( Ꜩ → T3 ) LATIN CAPITAL LETTER TZ → LATIN CAPITAL LETTER T, DIGIT THREE# →TƷ→
    {codepoint = 42801, with = "s"},    -- MA# ( ꜱ → s ) LATIN LETTER SMALL CAPITAL S → LATIN SMALL LETTER S#
    {codepoint = 42802, with = "AA"},   -- MA# ( Ꜳ → AA ) LATIN CAPITAL LETTER AA → LATIN CAPITAL LETTER A, LATIN CAPITAL LETTER A#
    {codepoint = 42803, with = "aa"},   -- MA# ( ꜳ → aa ) LATIN SMALL LETTER AA → LATIN SMALL LETTER A, LATIN SMALL LETTER A#
    {codepoint = 42804, with = "AO"},   -- MA# ( Ꜵ → AO ) LATIN CAPITAL LETTER AO → LATIN CAPITAL LETTER A, LATIN CAPITAL LETTER O#
    {codepoint = 42805, with = "ao"},   -- MA# ( ꜵ → ao ) LATIN SMALL LETTER AO → LATIN SMALL LETTER A, LATIN SMALL LETTER O#
    {codepoint = 42806, with = "AU"},   -- MA# ( Ꜷ → AU ) LATIN CAPITAL LETTER AU → LATIN CAPITAL LETTER A, LATIN CAPITAL LETTER U#
    {codepoint = 42807, with = "au"},   -- MA# ( ꜷ → au ) LATIN SMALL LETTER AU → LATIN SMALL LETTER A, LATIN SMALL LETTER U#
    {codepoint = 42808, with = "AV"},   -- MA# ( Ꜹ → AV ) LATIN CAPITAL LETTER AV → LATIN CAPITAL LETTER A, LATIN CAPITAL LETTER V#
    {codepoint = 42809, with = "av"},   -- MA# ( ꜹ → av ) LATIN SMALL LETTER AV → LATIN SMALL LETTER A, LATIN SMALL LETTER V#
    {codepoint = 42810, with = "AV"},   -- MA# ( Ꜻ → AV ) LATIN CAPITAL LETTER AV WITH HORIZONTAL BAR → LATIN CAPITAL LETTER A, LATIN CAPITAL LETTER V#
    {codepoint = 42811, with = "av"},   -- MA# ( ꜻ → av ) LATIN SMALL LETTER AV WITH HORIZONTAL BAR → LATIN SMALL LETTER A, LATIN SMALL LETTER V#
    {codepoint = 42812, with = "AY"},   -- MA# ( Ꜽ → AY ) LATIN CAPITAL LETTER AY → LATIN CAPITAL LETTER A, LATIN CAPITAL LETTER Y#
    {codepoint = 42813, with = "ay"},   -- MA# ( ꜽ → ay ) LATIN SMALL LETTER AY → LATIN SMALL LETTER A, LATIN SMALL LETTER Y#
    {codepoint = 42830, with = "OO"},   -- MA# ( Ꝏ → OO ) LATIN CAPITAL LETTER OO → LATIN CAPITAL LETTER O, LATIN CAPITAL LETTER O#
    {codepoint = 42831, with = "oo"},   -- MA# ( ꝏ → oo ) LATIN SMALL LETTER OO → LATIN SMALL LETTER O, LATIN SMALL LETTER O#
    {codepoint = 42842, with = "2"},    -- MA# ( Ꝛ → 2 ) LATIN CAPITAL LETTER R ROTUNDA → DIGIT TWO#
    {codepoint = 42858, with = "3"},    -- MA# ( Ꝫ → 3 ) LATIN CAPITAL LETTER ET → DIGIT THREE#
    {codepoint = 42862, with = "9"},    -- MA# ( Ꝯ → 9 ) LATIN CAPITAL LETTER CON → DIGIT NINE#
    {codepoint = 42871, with = "tf"},   -- MA# ( ꝷ → tf ) LATIN SMALL LETTER TUM → LATIN SMALL LETTER T, LATIN SMALL LETTER F#
    {codepoint = 42872, with = "&"},    -- MA# ( ꝸ → & ) LATIN SMALL LETTER UM → AMPERSAND#
    {codepoint = 42889, with = ":"},    -- MA#* ( ꞉ → : ) MODIFIER LETTER COLON → COLON#
    {codepoint = 42892, with = "'"},    -- MA# ( ꞌ → ' ) LATIN SMALL LETTER SALTILLO → APOSTROPHE#
    {codepoint = 42904, with = "F"},    -- MA# ( Ꞙ → F ) LATIN CAPITAL LETTER F WITH STROKE → LATIN CAPITAL LETTER F#
    {codepoint = 42905, with = "f"},    -- MA# ( ꞙ → f ) LATIN SMALL LETTER F WITH STROKE → LATIN SMALL LETTER F#
    {codepoint = 42911, with = "u"},    -- MA# ( ꞟ → u ) LATIN SMALL LETTER VOLAPUK UE → LATIN SMALL LETTER U#
    {codepoint = 42923, with = "3"},    -- MA# ( Ɜ → 3 ) LATIN CAPITAL LETTER REVERSED OPEN E → DIGIT THREE#
    {codepoint = 42930, with = "J"},    -- MA# ( Ʝ → J ) LATIN CAPITAL LETTER J WITH CROSSED-TAIL → LATIN CAPITAL LETTER J#
    {codepoint = 42931, with = "X"},    -- MA# ( Ꭓ → X ) LATIN CAPITAL LETTER CHI → LATIN CAPITAL LETTER X#
    {codepoint = 42932, with = "B"},    -- MA# ( Ꞵ → B ) LATIN CAPITAL LETTER BETA → LATIN CAPITAL LETTER B#
    {codepoint = 43826, with = "e"},    -- MA# ( ꬲ → e ) LATIN SMALL LETTER BLACKLETTER E → LATIN SMALL LETTER E#
    {codepoint = 43829, with = "f"},    -- MA# ( ꬵ → f ) LATIN SMALL LETTER LENIS F → LATIN SMALL LETTER F#
    {codepoint = 43837, with = "o"},    -- MA# ( ꬽ → o ) LATIN SMALL LETTER BLACKLETTER O → LATIN SMALL LETTER O#
    {codepoint = 43847, with = "r"},    -- MA# ( ꭇ → r ) LATIN SMALL LETTER R WITHOUT HANDLE → LATIN SMALL LETTER R#
    {codepoint = 43848, with = "r"},    -- MA# ( ꭈ → r ) LATIN SMALL LETTER DOUBLE R → LATIN SMALL LETTER R#
    {codepoint = 43854, with = "u"},    -- MA# ( ꭎ → u ) LATIN SMALL LETTER U WITH SHORT RIGHT LEG → LATIN SMALL LETTER U#
    {codepoint = 43858, with = "u"},    -- MA# ( ꭒ → u ) LATIN SMALL LETTER U WITH LEFT HOOK → LATIN SMALL LETTER U#
    {codepoint = 43866, with = "y"},    -- MA# ( ꭚ → y ) LATIN SMALL LETTER Y WITH SHORT RIGHT LEG → LATIN SMALL LETTER Y#
    {codepoint = 43875, with = "uo"},   -- MA# ( ꭣ → uo ) LATIN SMALL LETTER UO → LATIN SMALL LETTER U, LATIN SMALL LETTER O#
    {codepoint = 43893, with = "i"},    -- MA# ( ꭵ → i ) CHEROKEE SMALL LETTER V → LATIN SMALL LETTER I#
    {codepoint = 43905, with = "r"},    -- MA# ( ꮁ → r ) CHEROKEE SMALL LETTER HU → LATIN SMALL LETTER R# →ᴦ→→г→
    {codepoint = 43907, with = "w"},    -- MA# ( ꮃ → w ) CHEROKEE SMALL LETTER LA → LATIN SMALL LETTER W# →ᴡ→
    {codepoint = 43923, with = "z"},    -- MA# ( ꮓ → z ) CHEROKEE SMALL LETTER NO → LATIN SMALL LETTER Z# →ᴢ→
    {codepoint = 43945, with = "v"},    -- MA# ( ꮩ → v ) CHEROKEE SMALL LETTER DO → LATIN SMALL LETTER V# →ᴠ→
    {codepoint = 43946, with = "s"},    -- MA# ( ꮪ → s ) CHEROKEE SMALL LETTER DU → LATIN SMALL LETTER S# →ꜱ→
    {codepoint = 43951, with = "c"},    -- MA# ( ꮯ → c ) CHEROKEE SMALL LETTER TLI → LATIN SMALL LETTER C# →ᴄ→
    {codepoint = 64256, with = "ff"},   -- MA# ( ﬀ → ff ) LATIN SMALL LIGATURE FF → LATIN SMALL LETTER F, LATIN SMALL LETTER F#
    {codepoint = 64257, with = "fi"},   -- MA# ( ﬁ → fi ) LATIN SMALL LIGATURE FI → LATIN SMALL LETTER F, LATIN SMALL LETTER I#
    {codepoint = 64258, with = "fl"},   -- MA# ( ﬂ → fl ) LATIN SMALL LIGATURE FL → LATIN SMALL LETTER F, LATIN SMALL LETTER L#
    {codepoint = 64259, with = "ffi"},  -- MA# ( ﬃ → ffi ) LATIN SMALL LIGATURE FFI → LATIN SMALL LETTER F, LATIN SMALL LETTER F, LATIN SMALL LETTER I#
    {codepoint = 64260, with = "ffl"},  -- MA# ( ﬄ → ffl ) LATIN SMALL LIGATURE FFL → LATIN SMALL LETTER F, LATIN SMALL LETTER F, LATIN SMALL LETTER L#
    {codepoint = 64262, with = "st"},   -- MA# ( ﬆ → st ) LATIN SMALL LIGATURE ST → LATIN SMALL LETTER S, LATIN SMALL LETTER T#
    {codepoint = 64422, with = "o"},    -- MA# ( ‎ﮦ‎ → o ) ARABIC LETTER HEH GOAL ISOLATED FORM → LATIN SMALL LETTER O# →‎ه‎→
    {codepoint = 64423, with = "o"},    -- MA# ( ‎ﮧ‎ → o ) ARABIC LETTER HEH GOAL FINAL FORM → LATIN SMALL LETTER O# →‎ہ‎→→‎ه‎→
    {codepoint = 64424, with = "o"},    -- MA# ( ‎ﮨ‎ → o ) ARABIC LETTER HEH GOAL INITIAL FORM → LATIN SMALL LETTER O# →‎ہ‎→→‎ه‎→
    {codepoint = 64425, with = "o"},    -- MA# ( ‎ﮩ‎ → o ) ARABIC LETTER HEH GOAL MEDIAL FORM → LATIN SMALL LETTER O# →‎ہ‎→→‎ه‎→
    {codepoint = 64426, with = "o"},    -- MA# ( ‎ﮪ‎ → o ) ARABIC LETTER HEH DOACHASHMEE ISOLATED FORM → LATIN SMALL LETTER O# →‎ه‎→
    {codepoint = 64427, with = "o"},    -- MA# ( ‎ﮫ‎ → o ) ARABIC LETTER HEH DOACHASHMEE FINAL FORM → LATIN SMALL LETTER O# →‎ﻪ‎→→‎ه‎→
    {codepoint = 64428, with = "o"},    -- MA# ( ‎ﮬ‎ → o ) ARABIC LETTER HEH DOACHASHMEE INITIAL FORM → LATIN SMALL LETTER O# →‎ﻫ‎→→‎ه‎→
    {codepoint = 64429, with = "o"},    -- MA# ( ‎ﮭ‎ → o ) ARABIC LETTER HEH DOACHASHMEE MEDIAL FORM → LATIN SMALL LETTER O# →‎ﻬ‎→→‎ه‎→
    {codepoint = 64830, with = "("},    -- MA#* ( ﴾ → ( ) ORNATE LEFT PARENTHESIS → LEFT PARENTHESIS#
    {codepoint = 64831, with = ")"},    -- MA#* ( ﴿ → ) ) ORNATE RIGHT PARENTHESIS → RIGHT PARENTHESIS#
    {codepoint = 65072, with = ":"},    -- MA#* ( ︰ → : ) PRESENTATION FORM FOR VERTICAL TWO DOT LEADER → COLON#
    {codepoint = 65101, with = "_"},    -- MA# ( ﹍ → _ ) DASHED LOW LINE → LOW LINE#
    {codepoint = 65102, with = "_"},    -- MA# ( ﹎ → _ ) CENTRELINE LOW LINE → LOW LINE#
    {codepoint = 65103, with = "_"},    -- MA# ( ﹏ → _ ) WAVY LOW LINE → LOW LINE#
    {codepoint = 65112, with = "-"},    -- MA#* ( ﹘ → - ) SMALL EM DASH → HYPHEN-MINUS#
    {codepoint = 65128, with = "\\"},   -- MA#* ( ﹨ → \ ) SMALL REVERSE SOLIDUS → REVERSE SOLIDUS# →∖→
    {codepoint = 65165, with = "l"},    -- MA# ( ‎ﺍ‎ → l ) ARABIC LETTER ALEF ISOLATED FORM → LATIN SMALL LETTER L# →‎ا‎→→1→
    {codepoint = 65166, with = "l"},    -- MA# ( ‎ﺎ‎ → l ) ARABIC LETTER ALEF FINAL FORM → LATIN SMALL LETTER L# →‎ا‎→→1→
    {codepoint = 65257, with = "o"},    -- MA# ( ‎ﻩ‎ → o ) ARABIC LETTER HEH ISOLATED FORM → LATIN SMALL LETTER O# →‎ه‎→
    {codepoint = 65258, with = "o"},    -- MA# ( ‎ﻪ‎ → o ) ARABIC LETTER HEH FINAL FORM → LATIN SMALL LETTER O# →‎ه‎→
    {codepoint = 65259, with = "o"},    -- MA# ( ‎ﻫ‎ → o ) ARABIC LETTER HEH INITIAL FORM → LATIN SMALL LETTER O# →‎ه‎→
    {codepoint = 65260, with = "o"},    -- MA# ( ‎ﻬ‎ → o ) ARABIC LETTER HEH MEDIAL FORM → LATIN SMALL LETTER O# →‎ه‎→
    {codepoint = 65281, with = "!"},    -- MA#* ( ！ → ! ) FULLWIDTH EXCLAMATION MARK → EXCLAMATION MARK# →ǃ→
    {codepoint = 65282, with = "\""},   -- MA#* ( ＂ → '' ) FULLWIDTH QUOTATION MARK → APOSTROPHE, APOSTROPHE# →”→→with = "→# Converted to a quote.
    {codepoint = 65287, with = "'"},    -- MA#* ( ＇ → ' ) FULLWIDTH APOSTROPHE → APOSTROPHE# →’→
    {codepoint = 65306, with = ":"},    -- MA#* ( ： → : ) FULLWIDTH COLON → COLON# →︰→
    {codepoint = 65313, with = "A"},    -- MA# ( Ａ → A ) FULLWIDTH LATIN CAPITAL LETTER A → LATIN CAPITAL LETTER A# →А→
    {codepoint = 65314, with = "B"},    -- MA# ( Ｂ → B ) FULLWIDTH LATIN CAPITAL LETTER B → LATIN CAPITAL LETTER B# →Β→
    {codepoint = 65315, with = "C"},    -- MA# ( Ｃ → C ) FULLWIDTH LATIN CAPITAL LETTER C → LATIN CAPITAL LETTER C# →С→
    {codepoint = 65317, with = "E"},    -- MA# ( Ｅ → E ) FULLWIDTH LATIN CAPITAL LETTER E → LATIN CAPITAL LETTER E# →Ε→
    {codepoint = 65320, with = "H"},    -- MA# ( Ｈ → H ) FULLWIDTH LATIN CAPITAL LETTER H → LATIN CAPITAL LETTER H# →Η→
    {codepoint = 65321, with = "l"},    -- MA# ( Ｉ → l ) FULLWIDTH LATIN CAPITAL LETTER I → LATIN SMALL LETTER L# →Ӏ→
    {codepoint = 65322, with = "J"},    -- MA# ( Ｊ → J ) FULLWIDTH LATIN CAPITAL LETTER J → LATIN CAPITAL LETTER J# →Ј→
    {codepoint = 65323, with = "K"},    -- MA# ( Ｋ → K ) FULLWIDTH LATIN CAPITAL LETTER K → LATIN CAPITAL LETTER K# →Κ→
    {codepoint = 65325, with = "M"},    -- MA# ( Ｍ → M ) FULLWIDTH LATIN CAPITAL LETTER M → LATIN CAPITAL LETTER M# →Μ→
    {codepoint = 65326, with = "N"},    -- MA# ( Ｎ → N ) FULLWIDTH LATIN CAPITAL LETTER N → LATIN CAPITAL LETTER N# →Ν→
    {codepoint = 65327, with = "O"},    -- MA# ( Ｏ → O ) FULLWIDTH LATIN CAPITAL LETTER O → LATIN CAPITAL LETTER O# →О→
    {codepoint = 65328, with = "P"},    -- MA# ( Ｐ → P ) FULLWIDTH LATIN CAPITAL LETTER P → LATIN CAPITAL LETTER P# →Р→
    {codepoint = 65331, with = "S"},    -- MA# ( Ｓ → S ) FULLWIDTH LATIN CAPITAL LETTER S → LATIN CAPITAL LETTER S# →Ѕ→
    {codepoint = 65332, with = "T"},    -- MA# ( Ｔ → T ) FULLWIDTH LATIN CAPITAL LETTER T → LATIN CAPITAL LETTER T# →Т→
    {codepoint = 65336, with = "X"},    -- MA# ( Ｘ → X ) FULLWIDTH LATIN CAPITAL LETTER X → LATIN CAPITAL LETTER X# →Х→
    {codepoint = 65337, with = "Y"},    -- MA# ( Ｙ → Y ) FULLWIDTH LATIN CAPITAL LETTER Y → LATIN CAPITAL LETTER Y# →Υ→
    {codepoint = 65338, with = "Z"},    -- MA# ( Ｚ → Z ) FULLWIDTH LATIN CAPITAL LETTER Z → LATIN CAPITAL LETTER Z# →Ζ→
    {codepoint = 65339, with = "("},    -- MA#* ( ［ → ( ) FULLWIDTH LEFT SQUARE BRACKET → LEFT PARENTHESIS# →〔→
    {codepoint = 65340, with = "\\"},   -- MA#* ( ＼ → \ ) FULLWIDTH REVERSE SOLIDUS → REVERSE SOLIDUS# →∖→
    {codepoint = 65341, with = ")"},    -- MA#* ( ］ → ) ) FULLWIDTH RIGHT SQUARE BRACKET → RIGHT PARENTHESIS# →〕→
    {codepoint = 65344, with = "'"},    -- MA#* ( ｀ → ' ) FULLWIDTH GRAVE ACCENT → APOSTROPHE# →‘→
    {codepoint = 65345, with = "a"},    -- MA# ( ａ → a ) FULLWIDTH LATIN SMALL LETTER A → LATIN SMALL LETTER A# →а→
    {codepoint = 65347, with = "c"},    -- MA# ( ｃ → c ) FULLWIDTH LATIN SMALL LETTER C → LATIN SMALL LETTER C# →с→
    {codepoint = 65349, with = "e"},    -- MA# ( ｅ → e ) FULLWIDTH LATIN SMALL LETTER E → LATIN SMALL LETTER E# →е→
    {codepoint = 65351, with = "g"},    -- MA# ( ｇ → g ) FULLWIDTH LATIN SMALL LETTER G → LATIN SMALL LETTER G# →ɡ→
    {codepoint = 65352, with = "h"},    -- MA# ( ｈ → h ) FULLWIDTH LATIN SMALL LETTER H → LATIN SMALL LETTER H# →һ→
    {codepoint = 65353, with = "i"},    -- MA# ( ｉ → i ) FULLWIDTH LATIN SMALL LETTER I → LATIN SMALL LETTER I# →і→
    {codepoint = 65354, with = "j"},    -- MA# ( ｊ → j ) FULLWIDTH LATIN SMALL LETTER J → LATIN SMALL LETTER J# →ϳ→
    {codepoint = 65356, with = "l"},    -- MA# ( ｌ → l ) FULLWIDTH LATIN SMALL LETTER L → LATIN SMALL LETTER L# →Ⅰ→→Ӏ→
    {codepoint = 65359, with = "o"},    -- MA# ( ｏ → o ) FULLWIDTH LATIN SMALL LETTER O → LATIN SMALL LETTER O# →о→
    {codepoint = 65360, with = "p"},    -- MA# ( ｐ → p ) FULLWIDTH LATIN SMALL LETTER P → LATIN SMALL LETTER P# →р→
    {codepoint = 65363, with = "s"},    -- MA# ( ｓ → s ) FULLWIDTH LATIN SMALL LETTER S → LATIN SMALL LETTER S# →ѕ→
    {codepoint = 65366, with = "v"},    -- MA# ( ｖ → v ) FULLWIDTH LATIN SMALL LETTER V → LATIN SMALL LETTER V# →ν→
    {codepoint = 65368, with = "x"},    -- MA# ( ｘ → x ) FULLWIDTH LATIN SMALL LETTER X → LATIN SMALL LETTER X# →х→
    {codepoint = 65369, with = "y"},    -- MA# ( ｙ → y ) FULLWIDTH LATIN SMALL LETTER Y → LATIN SMALL LETTER Y# →у→
    {codepoint = 65512, with = "l"},    -- MA#* ( ￨ → l ) HALFWIDTH FORMS LIGHT VERTICAL → LATIN SMALL LETTER L# →|→
    {codepoint = 66178, with = "B"},    -- MA# ( 𐊂 → B ) LYCIAN LETTER B → LATIN CAPITAL LETTER B#
    {codepoint = 66182, with = "E"},    -- MA# ( 𐊆 → E ) LYCIAN LETTER I → LATIN CAPITAL LETTER E#
    {codepoint = 66183, with = "F"},    -- MA# ( 𐊇 → F ) LYCIAN LETTER W → LATIN CAPITAL LETTER F#
    {codepoint = 66186, with = "l"},    -- MA# ( 𐊊 → l ) LYCIAN LETTER J → LATIN SMALL LETTER L# →I→
    {codepoint = 66192, with = "X"},    -- MA# ( 𐊐 → X ) LYCIAN LETTER MM → LATIN CAPITAL LETTER X#
    {codepoint = 66194, with = "O"},    -- MA# ( 𐊒 → O ) LYCIAN LETTER U → LATIN CAPITAL LETTER O#
    {codepoint = 66197, with = "P"},    -- MA# ( 𐊕 → P ) LYCIAN LETTER R → LATIN CAPITAL LETTER P#
    {codepoint = 66198, with = "S"},    -- MA# ( 𐊖 → S ) LYCIAN LETTER S → LATIN CAPITAL LETTER S#
    {codepoint = 66199, with = "T"},    -- MA# ( 𐊗 → T ) LYCIAN LETTER T → LATIN CAPITAL LETTER T#
    {codepoint = 66203, with = "+"},    -- MA# ( 𐊛 → + ) LYCIAN LETTER H → PLUS SIGN#
    {codepoint = 66208, with = "A"},    -- MA# ( 𐊠 → A ) CARIAN LETTER A → LATIN CAPITAL LETTER A#
    {codepoint = 66209, with = "B"},    -- MA# ( 𐊡 → B ) CARIAN LETTER P2 → LATIN CAPITAL LETTER B#
    {codepoint = 66210, with = "C"},    -- MA# ( 𐊢 → C ) CARIAN LETTER D → LATIN CAPITAL LETTER C#
    {codepoint = 66213, with = "F"},    -- MA# ( 𐊥 → F ) CARIAN LETTER R → LATIN CAPITAL LETTER F#
    {codepoint = 66219, with = "O"},    -- MA# ( 𐊫 → O ) CARIAN LETTER O → LATIN CAPITAL LETTER O#
    {codepoint = 66224, with = "M"},    -- MA# ( 𐊰 → M ) CARIAN LETTER S → LATIN CAPITAL LETTER M#
    {codepoint = 66225, with = "T"},    -- MA# ( 𐊱 → T ) CARIAN LETTER C-18 → LATIN CAPITAL LETTER T#
    {codepoint = 66226, with = "Y"},    -- MA# ( 𐊲 → Y ) CARIAN LETTER U → LATIN CAPITAL LETTER Y#
    {codepoint = 66228, with = "X"},    -- MA# ( 𐊴 → X ) CARIAN LETTER X → LATIN CAPITAL LETTER X#
    {codepoint = 66255, with = "H"},    -- MA# ( 𐋏 → H ) CARIAN LETTER E2 → LATIN CAPITAL LETTER H#
    {codepoint = 66293, with = "Z"},    -- MA#* ( 𐋵 → Z ) COPTIC EPACT NUMBER THREE HUNDRED → LATIN CAPITAL LETTER Z#
    {codepoint = 66305, with = "B"},    -- MA# ( 𐌁 → B ) OLD ITALIC LETTER BE → LATIN CAPITAL LETTER B#
    {codepoint = 66306, with = "C"},    -- MA# ( 𐌂 → C ) OLD ITALIC LETTER KE → LATIN CAPITAL LETTER C#
    {codepoint = 66313, with = "l"},    -- MA# ( 𐌉 → l ) OLD ITALIC LETTER I → LATIN SMALL LETTER L# →I→
    {codepoint = 66321, with = "M"},    -- MA# ( 𐌑 → M ) OLD ITALIC LETTER SHE → LATIN CAPITAL LETTER M#
    {codepoint = 66325, with = "T"},    -- MA# ( 𐌕 → T ) OLD ITALIC LETTER TE → LATIN CAPITAL LETTER T#
    {codepoint = 66327, with = "X"},    -- MA# ( 𐌗 → X ) OLD ITALIC LETTER EKS → LATIN CAPITAL LETTER X#
    {codepoint = 66330, with = "8"},    -- MA# ( 𐌚 → 8 ) OLD ITALIC LETTER EF → DIGIT EIGHT#
    {codepoint = 66335, with = "*"},    -- MA# ( 𐌟 → * ) OLD ITALIC LETTER ESS → ASTERISK#
    {codepoint = 66336, with = "l"},    -- MA#* ( 𐌠 → l ) OLD ITALIC NUMERAL ONE → LATIN SMALL LETTER L# →𐌉→→I→
    {codepoint = 66338, with = "X"},    -- MA#* ( 𐌢 → X ) OLD ITALIC NUMERAL TEN → LATIN CAPITAL LETTER X# →𐌗→
    {codepoint = 66564, with = "O"},    -- MA# ( 𐐄 → O ) DESERET CAPITAL LETTER LONG O → LATIN CAPITAL LETTER O#
    {codepoint = 66581, with = "C"},    -- MA# ( 𐐕 → C ) DESERET CAPITAL LETTER CHEE → LATIN CAPITAL LETTER C#
    {codepoint = 66587, with = "L"},    -- MA# ( 𐐛 → L ) DESERET CAPITAL LETTER ETH → LATIN CAPITAL LETTER L#
    {codepoint = 66592, with = "S"},    -- MA# ( 𐐠 → S ) DESERET CAPITAL LETTER ZHEE → LATIN CAPITAL LETTER S#
    {codepoint = 66604, with = "o"},    -- MA# ( 𐐬 → o ) DESERET SMALL LETTER LONG O → LATIN SMALL LETTER O#
    {codepoint = 66621, with = "c"},    -- MA# ( 𐐽 → c ) DESERET SMALL LETTER CHEE → LATIN SMALL LETTER C#
    {codepoint = 66632, with = "s"},    -- MA# ( 𐑈 → s ) DESERET SMALL LETTER ZHEE → LATIN SMALL LETTER S#
    {codepoint = 66740, with = "R"},    -- MA# ( 𐒴 → R ) OSAGE CAPITAL LETTER BRA → LATIN CAPITAL LETTER R# →Ʀ→
    {codepoint = 66754, with = "O"},    -- MA# ( 𐓂 → O ) OSAGE CAPITAL LETTER O → LATIN CAPITAL LETTER O#
    {codepoint = 66766, with = "U"},    -- MA# ( 𐓎 → U ) OSAGE CAPITAL LETTER U → LATIN CAPITAL LETTER U#
    {codepoint = 66770, with = "7"},    -- MA# ( 𐓒 → 7 ) OSAGE CAPITAL LETTER ZA → DIGIT SEVEN#
    {codepoint = 66794, with = "o"},    -- MA# ( 𐓪 → o ) OSAGE SMALL LETTER O → LATIN SMALL LETTER O#
    {codepoint = 66806, with = "u"},    -- MA# ( 𐓶 → u ) OSAGE SMALL LETTER U → LATIN SMALL LETTER U# →ᴜ→
    {codepoint = 66835, with = "N"},    -- MA# ( 𐔓 → N ) ELBASAN LETTER NE → LATIN CAPITAL LETTER N#
    {codepoint = 66838, with = "O"},    -- MA# ( 𐔖 → O ) ELBASAN LETTER O → LATIN CAPITAL LETTER O#
    {codepoint = 66840, with = "K"},    -- MA# ( 𐔘 → K ) ELBASAN LETTER QE → LATIN CAPITAL LETTER K#
    {codepoint = 66844, with = "C"},    -- MA# ( 𐔜 → C ) ELBASAN LETTER SHE → LATIN CAPITAL LETTER C#
    {codepoint = 66845, with = "V"},    -- MA# ( 𐔝 → V ) ELBASAN LETTER TE → LATIN CAPITAL LETTER V#
    {codepoint = 66853, with = "F"},    -- MA# ( 𐔥 → F ) ELBASAN LETTER GHE → LATIN CAPITAL LETTER F#
    {codepoint = 66854, with = "L"},    -- MA# ( 𐔦 → L ) ELBASAN LETTER GHAMMA → LATIN CAPITAL LETTER L#
    {codepoint = 66855, with = "X"},    -- MA# ( 𐔧 → X ) ELBASAN LETTER KHE → LATIN CAPITAL LETTER X#
    {codepoint = 68176, with = "."},    -- MA#* ( ‎𐩐‎ → . ) KHAROSHTHI PUNCTUATION DOT → FULL STOP#
    {codepoint = 70864, with = "O"},    -- MA# ( 𑓐 → O ) TIRHUTA DIGIT ZERO → LATIN CAPITAL LETTER O# →০→→0→
    {codepoint = 71424, with = "rn"},   -- MA# ( 𑜀 → rn ) AHOM LETTER KA → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 71430, with = "v"},    -- MA# ( 𑜆 → v ) AHOM LETTER PA → LATIN SMALL LETTER V#
    {codepoint = 71434, with = "w"},    -- MA# ( 𑜊 → w ) AHOM LETTER JA → LATIN SMALL LETTER W#
    {codepoint = 71438, with = "w"},    -- MA# ( 𑜎 → w ) AHOM LETTER LA → LATIN SMALL LETTER W#
    {codepoint = 71439, with = "w"},    -- MA# ( 𑜏 → w ) AHOM LETTER SA → LATIN SMALL LETTER W#
    {codepoint = 71840, with = "V"},    -- MA# ( 𑢠 → V ) WARANG CITI CAPITAL LETTER NGAA → LATIN CAPITAL LETTER V#
    {codepoint = 71842, with = "F"},    -- MA# ( 𑢢 → F ) WARANG CITI CAPITAL LETTER WI → LATIN CAPITAL LETTER F#
    {codepoint = 71843, with = "L"},    -- MA# ( 𑢣 → L ) WARANG CITI CAPITAL LETTER YU → LATIN CAPITAL LETTER L#
    {codepoint = 71844, with = "Y"},    -- MA# ( 𑢤 → Y ) WARANG CITI CAPITAL LETTER YA → LATIN CAPITAL LETTER Y#
    {codepoint = 71846, with = "E"},    -- MA# ( 𑢦 → E ) WARANG CITI CAPITAL LETTER II → LATIN CAPITAL LETTER E#
    {codepoint = 71849, with = "Z"},    -- MA# ( 𑢩 → Z ) WARANG CITI CAPITAL LETTER O → LATIN CAPITAL LETTER Z#
    {codepoint = 71852, with = "9"},    -- MA# ( 𑢬 → 9 ) WARANG CITI CAPITAL LETTER KO → DIGIT NINE#
    {codepoint = 71854, with = "E"},    -- MA# ( 𑢮 → E ) WARANG CITI CAPITAL LETTER YUJ → LATIN CAPITAL LETTER E#
    {codepoint = 71855, with = "4"},    -- MA# ( 𑢯 → 4 ) WARANG CITI CAPITAL LETTER UC → DIGIT FOUR#
    {codepoint = 71858, with = "L"},    -- MA# ( 𑢲 → L ) WARANG CITI CAPITAL LETTER TTE → LATIN CAPITAL LETTER L#
    {codepoint = 71861, with = "O"},    -- MA# ( 𑢵 → O ) WARANG CITI CAPITAL LETTER AT → LATIN CAPITAL LETTER O#
    {codepoint = 71864, with = "U"},    -- MA# ( 𑢸 → U ) WARANG CITI CAPITAL LETTER PU → LATIN CAPITAL LETTER U#
    {codepoint = 71867, with = "5"},    -- MA# ( 𑢻 → 5 ) WARANG CITI CAPITAL LETTER HORR → DIGIT FIVE#
    {codepoint = 71868, with = "T"},    -- MA# ( 𑢼 → T ) WARANG CITI CAPITAL LETTER HAR → LATIN CAPITAL LETTER T#
    {codepoint = 71872, with = "v"},    -- MA# ( 𑣀 → v ) WARANG CITI SMALL LETTER NGAA → LATIN SMALL LETTER V#
    {codepoint = 71873, with = "s"},    -- MA# ( 𑣁 → s ) WARANG CITI SMALL LETTER A → LATIN SMALL LETTER S#
    {codepoint = 71874, with = "F"},    -- MA# ( 𑣂 → F ) WARANG CITI SMALL LETTER WI → LATIN CAPITAL LETTER F#
    {codepoint = 71875, with = "i"},    -- MA# ( 𑣃 → i ) WARANG CITI SMALL LETTER YU → LATIN SMALL LETTER I# →ι→
    {codepoint = 71876, with = "z"},    -- MA# ( 𑣄 → z ) WARANG CITI SMALL LETTER YA → LATIN SMALL LETTER Z#
    {codepoint = 71878, with = "7"},    -- MA# ( 𑣆 → 7 ) WARANG CITI SMALL LETTER II → DIGIT SEVEN#
    {codepoint = 71880, with = "o"},    -- MA# ( 𑣈 → o ) WARANG CITI SMALL LETTER E → LATIN SMALL LETTER O#
    {codepoint = 71882, with = "3"},    -- MA# ( 𑣊 → 3 ) WARANG CITI SMALL LETTER ANG → DIGIT THREE#
    {codepoint = 71884, with = "9"},    -- MA# ( 𑣌 → 9 ) WARANG CITI SMALL LETTER KO → DIGIT NINE#
    {codepoint = 71893, with = "6"},    -- MA# ( 𑣕 → 6 ) WARANG CITI SMALL LETTER AT → DIGIT SIX#
    {codepoint = 71894, with = "9"},    -- MA# ( 𑣖 → 9 ) WARANG CITI SMALL LETTER AM → DIGIT NINE#
    {codepoint = 71895, with = "o"},    -- MA# ( 𑣗 → o ) WARANG CITI SMALL LETTER BU → LATIN SMALL LETTER O#
    {codepoint = 71896, with = "u"},    -- MA# ( 𑣘 → u ) WARANG CITI SMALL LETTER PU → LATIN SMALL LETTER U# →υ→→ʋ→
    {codepoint = 71900, with = "y"},    -- MA# ( 𑣜 → y ) WARANG CITI SMALL LETTER HAR → LATIN SMALL LETTER Y# →ɣ→→γ→
    {codepoint = 71904, with = "O"},    -- MA# ( 𑣠 → O ) WARANG CITI DIGIT ZERO → LATIN CAPITAL LETTER O# →0→
    {codepoint = 71907, with = "rn"},   -- MA# ( 𑣣 → rn ) WARANG CITI DIGIT THREE → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 71909, with = "Z"},    -- MA# ( 𑣥 → Z ) WARANG CITI DIGIT FIVE → LATIN CAPITAL LETTER Z#
    {codepoint = 71910, with = "W"},    -- MA# ( 𑣦 → W ) WARANG CITI DIGIT SIX → LATIN CAPITAL LETTER W#
    {codepoint = 71913, with = "C"},    -- MA# ( 𑣩 → C ) WARANG CITI DIGIT NINE → LATIN CAPITAL LETTER C#
    {codepoint = 71916, with = "X"},    -- MA#* ( 𑣬 → X ) WARANG CITI NUMBER THIRTY → LATIN CAPITAL LETTER X#
    {codepoint = 71919, with = "W"},    -- MA#* ( 𑣯 → W ) WARANG CITI NUMBER SIXTY → LATIN CAPITAL LETTER W#
    {codepoint = 71922, with = "C"},    -- MA#* ( 𑣲 → C ) WARANG CITI NUMBER NINETY → LATIN CAPITAL LETTER C#
    {codepoint = 93960, with = "V"},    -- MA# ( 𖼈 → V ) MIAO LETTER VA → LATIN CAPITAL LETTER V#
    {codepoint = 93962, with = "T"},    -- MA# ( 𖼊 → T ) MIAO LETTER TA → LATIN CAPITAL LETTER T#
    {codepoint = 93974, with = "L"},    -- MA# ( 𖼖 → L ) MIAO LETTER LA → LATIN CAPITAL LETTER L#
    {codepoint = 93992, with = "l"},    -- MA# ( 𖼨 → l ) MIAO LETTER GHA → LATIN SMALL LETTER L# →I→
    {codepoint = 94005, with = "R"},    -- MA# ( 𖼵 → R ) MIAO LETTER ZHA → LATIN CAPITAL LETTER R#
    {codepoint = 94010, with = "S"},    -- MA# ( 𖼺 → S ) MIAO LETTER SA → LATIN CAPITAL LETTER S#
    {codepoint = 94011, with = "3"},    -- MA# ( 𖼻 → 3 ) MIAO LETTER ZA → DIGIT THREE# →Ʒ→
    {codepoint = 94015, with = ">"},    -- MA# ( 𖼿 → > ) MIAO LETTER ARCHAIC ZZA → GREATER-THAN SIGN#
    {codepoint = 94016, with = "A"},    -- MA# ( 𖽀 → A ) MIAO LETTER ZZYA → LATIN CAPITAL LETTER A#
    {codepoint = 94018, with = "U"},    -- MA# ( 𖽂 → U ) MIAO LETTER WA → LATIN CAPITAL LETTER U#
    {codepoint = 94019, with = "Y"},    -- MA# ( 𖽃 → Y ) MIAO LETTER AH → LATIN CAPITAL LETTER Y#
    {codepoint = 94033, with = "'"},    -- MA# ( 𖽑 → ' ) MIAO SIGN ASPIRATION → APOSTROPHE# →ʼ→→′→
    {codepoint = 94034, with = "'"},    -- MA# ( 𖽒 → ' ) MIAO SIGN REFORMED VOICING → APOSTROPHE# →ʻ→→‘→
    {codepoint = 119060, with = "{"},   -- MA#* ( 𝄔 → { ) MUSICAL SYMBOL BRACE → LEFT CURLY BRACKET#
    {codepoint = 119149, with = "."},   -- MA# ( 𝅭 → . ) MUSICAL SYMBOL COMBINING AUGMENTATION DOT → FULL STOP#
    {codepoint = 119302, with = "3"},   -- MA#* ( 𝈆 → 3 ) GREEK VOCAL NOTATION SYMBOL-7 → DIGIT THREE#
    {codepoint = 119309, with = "V"},   -- MA#* ( 𝈍 → V ) GREEK VOCAL NOTATION SYMBOL-14 → LATIN CAPITAL LETTER V#
    {codepoint = 119311, with = "\\"},  -- MA#* ( 𝈏 → \ ) GREEK VOCAL NOTATION SYMBOL-16 → REVERSE SOLIDUS#
    {codepoint = 119314, with = "7"},   -- MA#* ( 𝈒 → 7 ) GREEK VOCAL NOTATION SYMBOL-19 → DIGIT SEVEN#
    {codepoint = 119315, with = "F"},   -- MA#* ( 𝈓 → F ) GREEK VOCAL NOTATION SYMBOL-20 → LATIN CAPITAL LETTER F# →Ϝ→
    {codepoint = 119318, with = "R"},   -- MA#* ( 𝈖 → R ) GREEK VOCAL NOTATION SYMBOL-23 → LATIN CAPITAL LETTER R#
    {codepoint = 119338, with = "L"},   -- MA#* ( 𝈪 → L ) GREEK INSTRUMENTAL NOTATION SYMBOL-23 → LATIN CAPITAL LETTER L#
    {codepoint = 119350, with = "<"},   -- MA#* ( 𝈶 → < ) GREEK INSTRUMENTAL NOTATION SYMBOL-40 → LESS-THAN SIGN#
    {codepoint = 119351, with = ">"},   -- MA#* ( 𝈷 → > ) GREEK INSTRUMENTAL NOTATION SYMBOL-42 → GREATER-THAN SIGN#
    {codepoint = 119354, with = "/"},   -- MA#* ( 𝈺 → / ) GREEK INSTRUMENTAL NOTATION SYMBOL-47 → SOLIDUS#
    {codepoint = 119355, with = "\\"},  -- MA#* ( 𝈻 → \ ) GREEK INSTRUMENTAL NOTATION SYMBOL-48 → REVERSE SOLIDUS# →𝈏→
    {codepoint = 119808, with = "A"},   -- MA# ( 𝐀 → A ) MATHEMATICAL BOLD CAPITAL A → LATIN CAPITAL LETTER A#
    {codepoint = 119809, with = "B"},   -- MA# ( 𝐁 → B ) MATHEMATICAL BOLD CAPITAL B → LATIN CAPITAL LETTER B#
    {codepoint = 119810, with = "C"},   -- MA# ( 𝐂 → C ) MATHEMATICAL BOLD CAPITAL C → LATIN CAPITAL LETTER C#
    {codepoint = 119811, with = "D"},   -- MA# ( 𝐃 → D ) MATHEMATICAL BOLD CAPITAL D → LATIN CAPITAL LETTER D#
    {codepoint = 119812, with = "E"},   -- MA# ( 𝐄 → E ) MATHEMATICAL BOLD CAPITAL E → LATIN CAPITAL LETTER E#
    {codepoint = 119813, with = "F"},   -- MA# ( 𝐅 → F ) MATHEMATICAL BOLD CAPITAL F → LATIN CAPITAL LETTER F#
    {codepoint = 119814, with = "G"},   -- MA# ( 𝐆 → G ) MATHEMATICAL BOLD CAPITAL G → LATIN CAPITAL LETTER G#
    {codepoint = 119815, with = "H"},   -- MA# ( 𝐇 → H ) MATHEMATICAL BOLD CAPITAL H → LATIN CAPITAL LETTER H#
    {codepoint = 119816, with = "l"},   -- MA# ( 𝐈 → l ) MATHEMATICAL BOLD CAPITAL I → LATIN SMALL LETTER L# →I→
    {codepoint = 119817, with = "J"},   -- MA# ( 𝐉 → J ) MATHEMATICAL BOLD CAPITAL J → LATIN CAPITAL LETTER J#
    {codepoint = 119818, with = "K"},   -- MA# ( 𝐊 → K ) MATHEMATICAL BOLD CAPITAL K → LATIN CAPITAL LETTER K#
    {codepoint = 119819, with = "L"},   -- MA# ( 𝐋 → L ) MATHEMATICAL BOLD CAPITAL L → LATIN CAPITAL LETTER L#
    {codepoint = 119820, with = "M"},   -- MA# ( 𝐌 → M ) MATHEMATICAL BOLD CAPITAL M → LATIN CAPITAL LETTER M#
    {codepoint = 119821, with = "N"},   -- MA# ( 𝐍 → N ) MATHEMATICAL BOLD CAPITAL N → LATIN CAPITAL LETTER N#
    {codepoint = 119822, with = "O"},   -- MA# ( 𝐎 → O ) MATHEMATICAL BOLD CAPITAL O → LATIN CAPITAL LETTER O#
    {codepoint = 119823, with = "P"},   -- MA# ( 𝐏 → P ) MATHEMATICAL BOLD CAPITAL P → LATIN CAPITAL LETTER P#
    {codepoint = 119824, with = "Q"},   -- MA# ( 𝐐 → Q ) MATHEMATICAL BOLD CAPITAL Q → LATIN CAPITAL LETTER Q#
    {codepoint = 119825, with = "R"},   -- MA# ( 𝐑 → R ) MATHEMATICAL BOLD CAPITAL R → LATIN CAPITAL LETTER R#
    {codepoint = 119826, with = "S"},   -- MA# ( 𝐒 → S ) MATHEMATICAL BOLD CAPITAL S → LATIN CAPITAL LETTER S#
    {codepoint = 119827, with = "T"},   -- MA# ( 𝐓 → T ) MATHEMATICAL BOLD CAPITAL T → LATIN CAPITAL LETTER T#
    {codepoint = 119828, with = "U"},   -- MA# ( 𝐔 → U ) MATHEMATICAL BOLD CAPITAL U → LATIN CAPITAL LETTER U#
    {codepoint = 119829, with = "V"},   -- MA# ( 𝐕 → V ) MATHEMATICAL BOLD CAPITAL V → LATIN CAPITAL LETTER V#
    {codepoint = 119830, with = "W"},   -- MA# ( 𝐖 → W ) MATHEMATICAL BOLD CAPITAL W → LATIN CAPITAL LETTER W#
    {codepoint = 119831, with = "X"},   -- MA# ( 𝐗 → X ) MATHEMATICAL BOLD CAPITAL X → LATIN CAPITAL LETTER X#
    {codepoint = 119832, with = "Y"},   -- MA# ( 𝐘 → Y ) MATHEMATICAL BOLD CAPITAL Y → LATIN CAPITAL LETTER Y#
    {codepoint = 119833, with = "Z"},   -- MA# ( 𝐙 → Z ) MATHEMATICAL BOLD CAPITAL Z → LATIN CAPITAL LETTER Z#
    {codepoint = 119834, with = "a"},   -- MA# ( 𝐚 → a ) MATHEMATICAL BOLD SMALL A → LATIN SMALL LETTER A#
    {codepoint = 119835, with = "b"},   -- MA# ( 𝐛 → b ) MATHEMATICAL BOLD SMALL B → LATIN SMALL LETTER B#
    {codepoint = 119836, with = "c"},   -- MA# ( 𝐜 → c ) MATHEMATICAL BOLD SMALL C → LATIN SMALL LETTER C#
    {codepoint = 119837, with = "d"},   -- MA# ( 𝐝 → d ) MATHEMATICAL BOLD SMALL D → LATIN SMALL LETTER D#
    {codepoint = 119838, with = "e"},   -- MA# ( 𝐞 → e ) MATHEMATICAL BOLD SMALL E → LATIN SMALL LETTER E#
    {codepoint = 119839, with = "f"},   -- MA# ( 𝐟 → f ) MATHEMATICAL BOLD SMALL F → LATIN SMALL LETTER F#
    {codepoint = 119840, with = "g"},   -- MA# ( 𝐠 → g ) MATHEMATICAL BOLD SMALL G → LATIN SMALL LETTER G#
    {codepoint = 119841, with = "h"},   -- MA# ( 𝐡 → h ) MATHEMATICAL BOLD SMALL H → LATIN SMALL LETTER H#
    {codepoint = 119842, with = "i"},   -- MA# ( 𝐢 → i ) MATHEMATICAL BOLD SMALL I → LATIN SMALL LETTER I#
    {codepoint = 119843, with = "j"},   -- MA# ( 𝐣 → j ) MATHEMATICAL BOLD SMALL J → LATIN SMALL LETTER J#
    {codepoint = 119844, with = "k"},   -- MA# ( 𝐤 → k ) MATHEMATICAL BOLD SMALL K → LATIN SMALL LETTER K#
    {codepoint = 119845, with = "l"},   -- MA# ( 𝐥 → l ) MATHEMATICAL BOLD SMALL L → LATIN SMALL LETTER L#
    {codepoint = 119846, with = "rn"},  -- MA# ( 𝐦 → rn ) MATHEMATICAL BOLD SMALL M → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 119847, with = "n"},   -- MA# ( 𝐧 → n ) MATHEMATICAL BOLD SMALL N → LATIN SMALL LETTER N#
    {codepoint = 119848, with = "o"},   -- MA# ( 𝐨 → o ) MATHEMATICAL BOLD SMALL O → LATIN SMALL LETTER O#
    {codepoint = 119849, with = "p"},   -- MA# ( 𝐩 → p ) MATHEMATICAL BOLD SMALL P → LATIN SMALL LETTER P#
    {codepoint = 119850, with = "q"},   -- MA# ( 𝐪 → q ) MATHEMATICAL BOLD SMALL Q → LATIN SMALL LETTER Q#
    {codepoint = 119851, with = "r"},   -- MA# ( 𝐫 → r ) MATHEMATICAL BOLD SMALL R → LATIN SMALL LETTER R#
    {codepoint = 119852, with = "s"},   -- MA# ( 𝐬 → s ) MATHEMATICAL BOLD SMALL S → LATIN SMALL LETTER S#
    {codepoint = 119853, with = "t"},   -- MA# ( 𝐭 → t ) MATHEMATICAL BOLD SMALL T → LATIN SMALL LETTER T#
    {codepoint = 119854, with = "u"},   -- MA# ( 𝐮 → u ) MATHEMATICAL BOLD SMALL U → LATIN SMALL LETTER U#
    {codepoint = 119855, with = "v"},   -- MA# ( 𝐯 → v ) MATHEMATICAL BOLD SMALL V → LATIN SMALL LETTER V#
    {codepoint = 119856, with = "w"},   -- MA# ( 𝐰 → w ) MATHEMATICAL BOLD SMALL W → LATIN SMALL LETTER W#
    {codepoint = 119857, with = "x"},   -- MA# ( 𝐱 → x ) MATHEMATICAL BOLD SMALL X → LATIN SMALL LETTER X#
    {codepoint = 119858, with = "y"},   -- MA# ( 𝐲 → y ) MATHEMATICAL BOLD SMALL Y → LATIN SMALL LETTER Y#
    {codepoint = 119859, with = "z"},   -- MA# ( 𝐳 → z ) MATHEMATICAL BOLD SMALL Z → LATIN SMALL LETTER Z#
    {codepoint = 119860, with = "A"},   -- MA# ( 𝐴 → A ) MATHEMATICAL ITALIC CAPITAL A → LATIN CAPITAL LETTER A#
    {codepoint = 119861, with = "B"},   -- MA# ( 𝐵 → B ) MATHEMATICAL ITALIC CAPITAL B → LATIN CAPITAL LETTER B#
    {codepoint = 119862, with = "C"},   -- MA# ( 𝐶 → C ) MATHEMATICAL ITALIC CAPITAL C → LATIN CAPITAL LETTER C#
    {codepoint = 119863, with = "D"},   -- MA# ( 𝐷 → D ) MATHEMATICAL ITALIC CAPITAL D → LATIN CAPITAL LETTER D#
    {codepoint = 119864, with = "E"},   -- MA# ( 𝐸 → E ) MATHEMATICAL ITALIC CAPITAL E → LATIN CAPITAL LETTER E#
    {codepoint = 119865, with = "F"},   -- MA# ( 𝐹 → F ) MATHEMATICAL ITALIC CAPITAL F → LATIN CAPITAL LETTER F#
    {codepoint = 119866, with = "G"},   -- MA# ( 𝐺 → G ) MATHEMATICAL ITALIC CAPITAL G → LATIN CAPITAL LETTER G#
    {codepoint = 119867, with = "H"},   -- MA# ( 𝐻 → H ) MATHEMATICAL ITALIC CAPITAL H → LATIN CAPITAL LETTER H#
    {codepoint = 119868, with = "l"},   -- MA# ( 𝐼 → l ) MATHEMATICAL ITALIC CAPITAL I → LATIN SMALL LETTER L# →I→
    {codepoint = 119869, with = "J"},   -- MA# ( 𝐽 → J ) MATHEMATICAL ITALIC CAPITAL J → LATIN CAPITAL LETTER J#
    {codepoint = 119870, with = "K"},   -- MA# ( 𝐾 → K ) MATHEMATICAL ITALIC CAPITAL K → LATIN CAPITAL LETTER K#
    {codepoint = 119871, with = "L"},   -- MA# ( 𝐿 → L ) MATHEMATICAL ITALIC CAPITAL L → LATIN CAPITAL LETTER L#
    {codepoint = 119872, with = "M"},   -- MA# ( 𝑀 → M ) MATHEMATICAL ITALIC CAPITAL M → LATIN CAPITAL LETTER M#
    {codepoint = 119873, with = "N"},   -- MA# ( 𝑁 → N ) MATHEMATICAL ITALIC CAPITAL N → LATIN CAPITAL LETTER N#
    {codepoint = 119874, with = "O"},   -- MA# ( 𝑂 → O ) MATHEMATICAL ITALIC CAPITAL O → LATIN CAPITAL LETTER O#
    {codepoint = 119875, with = "P"},   -- MA# ( 𝑃 → P ) MATHEMATICAL ITALIC CAPITAL P → LATIN CAPITAL LETTER P#
    {codepoint = 119876, with = "Q"},   -- MA# ( 𝑄 → Q ) MATHEMATICAL ITALIC CAPITAL Q → LATIN CAPITAL LETTER Q#
    {codepoint = 119877, with = "R"},   -- MA# ( 𝑅 → R ) MATHEMATICAL ITALIC CAPITAL R → LATIN CAPITAL LETTER R#
    {codepoint = 119878, with = "S"},   -- MA# ( 𝑆 → S ) MATHEMATICAL ITALIC CAPITAL S → LATIN CAPITAL LETTER S#
    {codepoint = 119879, with = "T"},   -- MA# ( 𝑇 → T ) MATHEMATICAL ITALIC CAPITAL T → LATIN CAPITAL LETTER T#
    {codepoint = 119880, with = "U"},   -- MA# ( 𝑈 → U ) MATHEMATICAL ITALIC CAPITAL U → LATIN CAPITAL LETTER U#
    {codepoint = 119881, with = "V"},   -- MA# ( 𝑉 → V ) MATHEMATICAL ITALIC CAPITAL V → LATIN CAPITAL LETTER V#
    {codepoint = 119882, with = "W"},   -- MA# ( 𝑊 → W ) MATHEMATICAL ITALIC CAPITAL W → LATIN CAPITAL LETTER W#
    {codepoint = 119883, with = "X"},   -- MA# ( 𝑋 → X ) MATHEMATICAL ITALIC CAPITAL X → LATIN CAPITAL LETTER X#
    {codepoint = 119884, with = "Y"},   -- MA# ( 𝑌 → Y ) MATHEMATICAL ITALIC CAPITAL Y → LATIN CAPITAL LETTER Y#
    {codepoint = 119885, with = "Z"},   -- MA# ( 𝑍 → Z ) MATHEMATICAL ITALIC CAPITAL Z → LATIN CAPITAL LETTER Z#
    {codepoint = 119886, with = "a"},   -- MA# ( 𝑎 → a ) MATHEMATICAL ITALIC SMALL A → LATIN SMALL LETTER A#
    {codepoint = 119887, with = "b"},   -- MA# ( 𝑏 → b ) MATHEMATICAL ITALIC SMALL B → LATIN SMALL LETTER B#
    {codepoint = 119888, with = "c"},   -- MA# ( 𝑐 → c ) MATHEMATICAL ITALIC SMALL C → LATIN SMALL LETTER C#
    {codepoint = 119889, with = "d"},   -- MA# ( 𝑑 → d ) MATHEMATICAL ITALIC SMALL D → LATIN SMALL LETTER D#
    {codepoint = 119890, with = "e"},   -- MA# ( 𝑒 → e ) MATHEMATICAL ITALIC SMALL E → LATIN SMALL LETTER E#
    {codepoint = 119891, with = "f"},   -- MA# ( 𝑓 → f ) MATHEMATICAL ITALIC SMALL F → LATIN SMALL LETTER F#
    {codepoint = 119892, with = "g"},   -- MA# ( 𝑔 → g ) MATHEMATICAL ITALIC SMALL G → LATIN SMALL LETTER G#
    {codepoint = 119894, with = "i"},   -- MA# ( 𝑖 → i ) MATHEMATICAL ITALIC SMALL I → LATIN SMALL LETTER I#
    {codepoint = 119895, with = "j"},   -- MA# ( 𝑗 → j ) MATHEMATICAL ITALIC SMALL J → LATIN SMALL LETTER J#
    {codepoint = 119896, with = "k"},   -- MA# ( 𝑘 → k ) MATHEMATICAL ITALIC SMALL K → LATIN SMALL LETTER K#
    {codepoint = 119897, with = "l"},   -- MA# ( 𝑙 → l ) MATHEMATICAL ITALIC SMALL L → LATIN SMALL LETTER L#
    {codepoint = 119898, with = "rn"},  -- MA# ( 𝑚 → rn ) MATHEMATICAL ITALIC SMALL M → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 119899, with = "n"},   -- MA# ( 𝑛 → n ) MATHEMATICAL ITALIC SMALL N → LATIN SMALL LETTER N#
    {codepoint = 119900, with = "o"},   -- MA# ( 𝑜 → o ) MATHEMATICAL ITALIC SMALL O → LATIN SMALL LETTER O#
    {codepoint = 119901, with = "p"},   -- MA# ( 𝑝 → p ) MATHEMATICAL ITALIC SMALL P → LATIN SMALL LETTER P#
    {codepoint = 119902, with = "q"},   -- MA# ( 𝑞 → q ) MATHEMATICAL ITALIC SMALL Q → LATIN SMALL LETTER Q#
    {codepoint = 119903, with = "r"},   -- MA# ( 𝑟 → r ) MATHEMATICAL ITALIC SMALL R → LATIN SMALL LETTER R#
    {codepoint = 119904, with = "s"},   -- MA# ( 𝑠 → s ) MATHEMATICAL ITALIC SMALL S → LATIN SMALL LETTER S#
    {codepoint = 119905, with = "t"},   -- MA# ( 𝑡 → t ) MATHEMATICAL ITALIC SMALL T → LATIN SMALL LETTER T#
    {codepoint = 119906, with = "u"},   -- MA# ( 𝑢 → u ) MATHEMATICAL ITALIC SMALL U → LATIN SMALL LETTER U#
    {codepoint = 119907, with = "v"},   -- MA# ( 𝑣 → v ) MATHEMATICAL ITALIC SMALL V → LATIN SMALL LETTER V#
    {codepoint = 119908, with = "w"},   -- MA# ( 𝑤 → w ) MATHEMATICAL ITALIC SMALL W → LATIN SMALL LETTER W#
    {codepoint = 119909, with = "x"},   -- MA# ( 𝑥 → x ) MATHEMATICAL ITALIC SMALL X → LATIN SMALL LETTER X#
    {codepoint = 119910, with = "y"},   -- MA# ( 𝑦 → y ) MATHEMATICAL ITALIC SMALL Y → LATIN SMALL LETTER Y#
    {codepoint = 119911, with = "z"},   -- MA# ( 𝑧 → z ) MATHEMATICAL ITALIC SMALL Z → LATIN SMALL LETTER Z#
    {codepoint = 119912, with = "A"},   -- MA# ( 𝑨 → A ) MATHEMATICAL BOLD ITALIC CAPITAL A → LATIN CAPITAL LETTER A#
    {codepoint = 119913, with = "B"},   -- MA# ( 𝑩 → B ) MATHEMATICAL BOLD ITALIC CAPITAL B → LATIN CAPITAL LETTER B#
    {codepoint = 119914, with = "C"},   -- MA# ( 𝑪 → C ) MATHEMATICAL BOLD ITALIC CAPITAL C → LATIN CAPITAL LETTER C#
    {codepoint = 119915, with = "D"},   -- MA# ( 𝑫 → D ) MATHEMATICAL BOLD ITALIC CAPITAL D → LATIN CAPITAL LETTER D#
    {codepoint = 119916, with = "E"},   -- MA# ( 𝑬 → E ) MATHEMATICAL BOLD ITALIC CAPITAL E → LATIN CAPITAL LETTER E#
    {codepoint = 119917, with = "F"},   -- MA# ( 𝑭 → F ) MATHEMATICAL BOLD ITALIC CAPITAL F → LATIN CAPITAL LETTER F#
    {codepoint = 119918, with = "G"},   -- MA# ( 𝑮 → G ) MATHEMATICAL BOLD ITALIC CAPITAL G → LATIN CAPITAL LETTER G#
    {codepoint = 119919, with = "H"},   -- MA# ( 𝑯 → H ) MATHEMATICAL BOLD ITALIC CAPITAL H → LATIN CAPITAL LETTER H#
    {codepoint = 119920, with = "l"},   -- MA# ( 𝑰 → l ) MATHEMATICAL BOLD ITALIC CAPITAL I → LATIN SMALL LETTER L# →I→
    {codepoint = 119921, with = "J"},   -- MA# ( 𝑱 → J ) MATHEMATICAL BOLD ITALIC CAPITAL J → LATIN CAPITAL LETTER J#
    {codepoint = 119922, with = "K"},   -- MA# ( 𝑲 → K ) MATHEMATICAL BOLD ITALIC CAPITAL K → LATIN CAPITAL LETTER K#
    {codepoint = 119923, with = "L"},   -- MA# ( 𝑳 → L ) MATHEMATICAL BOLD ITALIC CAPITAL L → LATIN CAPITAL LETTER L#
    {codepoint = 119924, with = "M"},   -- MA# ( 𝑴 → M ) MATHEMATICAL BOLD ITALIC CAPITAL M → LATIN CAPITAL LETTER M#
    {codepoint = 119925, with = "N"},   -- MA# ( 𝑵 → N ) MATHEMATICAL BOLD ITALIC CAPITAL N → LATIN CAPITAL LETTER N#
    {codepoint = 119926, with = "O"},   -- MA# ( 𝑶 → O ) MATHEMATICAL BOLD ITALIC CAPITAL O → LATIN CAPITAL LETTER O#
    {codepoint = 119927, with = "P"},   -- MA# ( 𝑷 → P ) MATHEMATICAL BOLD ITALIC CAPITAL P → LATIN CAPITAL LETTER P#
    {codepoint = 119928, with = "Q"},   -- MA# ( 𝑸 → Q ) MATHEMATICAL BOLD ITALIC CAPITAL Q → LATIN CAPITAL LETTER Q#
    {codepoint = 119929, with = "R"},   -- MA# ( 𝑹 → R ) MATHEMATICAL BOLD ITALIC CAPITAL R → LATIN CAPITAL LETTER R#
    {codepoint = 119930, with = "S"},   -- MA# ( 𝑺 → S ) MATHEMATICAL BOLD ITALIC CAPITAL S → LATIN CAPITAL LETTER S#
    {codepoint = 119931, with = "T"},   -- MA# ( 𝑻 → T ) MATHEMATICAL BOLD ITALIC CAPITAL T → LATIN CAPITAL LETTER T#
    {codepoint = 119932, with = "U"},   -- MA# ( 𝑼 → U ) MATHEMATICAL BOLD ITALIC CAPITAL U → LATIN CAPITAL LETTER U#
    {codepoint = 119933, with = "V"},   -- MA# ( 𝑽 → V ) MATHEMATICAL BOLD ITALIC CAPITAL V → LATIN CAPITAL LETTER V#
    {codepoint = 119934, with = "W"},   -- MA# ( 𝑾 → W ) MATHEMATICAL BOLD ITALIC CAPITAL W → LATIN CAPITAL LETTER W#
    {codepoint = 119935, with = "X"},   -- MA# ( 𝑿 → X ) MATHEMATICAL BOLD ITALIC CAPITAL X → LATIN CAPITAL LETTER X#
    {codepoint = 119936, with = "Y"},   -- MA# ( 𝒀 → Y ) MATHEMATICAL BOLD ITALIC CAPITAL Y → LATIN CAPITAL LETTER Y#
    {codepoint = 119937, with = "Z"},   -- MA# ( 𝒁 → Z ) MATHEMATICAL BOLD ITALIC CAPITAL Z → LATIN CAPITAL LETTER Z#
    {codepoint = 119938, with = "a"},   -- MA# ( 𝒂 → a ) MATHEMATICAL BOLD ITALIC SMALL A → LATIN SMALL LETTER A#
    {codepoint = 119939, with = "b"},   -- MA# ( 𝒃 → b ) MATHEMATICAL BOLD ITALIC SMALL B → LATIN SMALL LETTER B#
    {codepoint = 119940, with = "c"},   -- MA# ( 𝒄 → c ) MATHEMATICAL BOLD ITALIC SMALL C → LATIN SMALL LETTER C#
    {codepoint = 119941, with = "d"},   -- MA# ( 𝒅 → d ) MATHEMATICAL BOLD ITALIC SMALL D → LATIN SMALL LETTER D#
    {codepoint = 119942, with = "e"},   -- MA# ( 𝒆 → e ) MATHEMATICAL BOLD ITALIC SMALL E → LATIN SMALL LETTER E#
    {codepoint = 119943, with = "f"},   -- MA# ( 𝒇 → f ) MATHEMATICAL BOLD ITALIC SMALL F → LATIN SMALL LETTER F#
    {codepoint = 119944, with = "g"},   -- MA# ( 𝒈 → g ) MATHEMATICAL BOLD ITALIC SMALL G → LATIN SMALL LETTER G#
    {codepoint = 119945, with = "h"},   -- MA# ( 𝒉 → h ) MATHEMATICAL BOLD ITALIC SMALL H → LATIN SMALL LETTER H#
    {codepoint = 119946, with = "i"},   -- MA# ( 𝒊 → i ) MATHEMATICAL BOLD ITALIC SMALL I → LATIN SMALL LETTER I#
    {codepoint = 119947, with = "j"},   -- MA# ( 𝒋 → j ) MATHEMATICAL BOLD ITALIC SMALL J → LATIN SMALL LETTER J#
    {codepoint = 119948, with = "k"},   -- MA# ( 𝒌 → k ) MATHEMATICAL BOLD ITALIC SMALL K → LATIN SMALL LETTER K#
    {codepoint = 119949, with = "l"},   -- MA# ( 𝒍 → l ) MATHEMATICAL BOLD ITALIC SMALL L → LATIN SMALL LETTER L#
    {codepoint = 119950, with = "rn"},  -- MA# ( 𝒎 → rn ) MATHEMATICAL BOLD ITALIC SMALL M → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 119951, with = "n"},   -- MA# ( 𝒏 → n ) MATHEMATICAL BOLD ITALIC SMALL N → LATIN SMALL LETTER N#
    {codepoint = 119952, with = "o"},   -- MA# ( 𝒐 → o ) MATHEMATICAL BOLD ITALIC SMALL O → LATIN SMALL LETTER O#
    {codepoint = 119953, with = "p"},   -- MA# ( 𝒑 → p ) MATHEMATICAL BOLD ITALIC SMALL P → LATIN SMALL LETTER P#
    {codepoint = 119954, with = "q"},   -- MA# ( 𝒒 → q ) MATHEMATICAL BOLD ITALIC SMALL Q → LATIN SMALL LETTER Q#
    {codepoint = 119955, with = "r"},   -- MA# ( 𝒓 → r ) MATHEMATICAL BOLD ITALIC SMALL R → LATIN SMALL LETTER R#
    {codepoint = 119956, with = "s"},   -- MA# ( 𝒔 → s ) MATHEMATICAL BOLD ITALIC SMALL S → LATIN SMALL LETTER S#
    {codepoint = 119957, with = "t"},   -- MA# ( 𝒕 → t ) MATHEMATICAL BOLD ITALIC SMALL T → LATIN SMALL LETTER T#
    {codepoint = 119958, with = "u"},   -- MA# ( 𝒖 → u ) MATHEMATICAL BOLD ITALIC SMALL U → LATIN SMALL LETTER U#
    {codepoint = 119959, with = "v"},   -- MA# ( 𝒗 → v ) MATHEMATICAL BOLD ITALIC SMALL V → LATIN SMALL LETTER V#
    {codepoint = 119960, with = "w"},   -- MA# ( 𝒘 → w ) MATHEMATICAL BOLD ITALIC SMALL W → LATIN SMALL LETTER W#
    {codepoint = 119961, with = "x"},   -- MA# ( 𝒙 → x ) MATHEMATICAL BOLD ITALIC SMALL X → LATIN SMALL LETTER X#
    {codepoint = 119962, with = "y"},   -- MA# ( 𝒚 → y ) MATHEMATICAL BOLD ITALIC SMALL Y → LATIN SMALL LETTER Y#
    {codepoint = 119963, with = "z"},   -- MA# ( 𝒛 → z ) MATHEMATICAL BOLD ITALIC SMALL Z → LATIN SMALL LETTER Z#
    {codepoint = 119964, with = "A"},   -- MA# ( 𝒜 → A ) MATHEMATICAL SCRIPT CAPITAL A → LATIN CAPITAL LETTER A#
    {codepoint = 119966, with = "C"},   -- MA# ( 𝒞 → C ) MATHEMATICAL SCRIPT CAPITAL C → LATIN CAPITAL LETTER C#
    {codepoint = 119967, with = "D"},   -- MA# ( 𝒟 → D ) MATHEMATICAL SCRIPT CAPITAL D → LATIN CAPITAL LETTER D#
    {codepoint = 119970, with = "G"},   -- MA# ( 𝒢 → G ) MATHEMATICAL SCRIPT CAPITAL G → LATIN CAPITAL LETTER G#
    {codepoint = 119973, with = "J"},   -- MA# ( 𝒥 → J ) MATHEMATICAL SCRIPT CAPITAL J → LATIN CAPITAL LETTER J#
    {codepoint = 119974, with = "K"},   -- MA# ( 𝒦 → K ) MATHEMATICAL SCRIPT CAPITAL K → LATIN CAPITAL LETTER K#
    {codepoint = 119977, with = "N"},   -- MA# ( 𝒩 → N ) MATHEMATICAL SCRIPT CAPITAL N → LATIN CAPITAL LETTER N#
    {codepoint = 119978, with = "O"},   -- MA# ( 𝒪 → O ) MATHEMATICAL SCRIPT CAPITAL O → LATIN CAPITAL LETTER O#
    {codepoint = 119979, with = "P"},   -- MA# ( 𝒫 → P ) MATHEMATICAL SCRIPT CAPITAL P → LATIN CAPITAL LETTER P#
    {codepoint = 119980, with = "Q"},   -- MA# ( 𝒬 → Q ) MATHEMATICAL SCRIPT CAPITAL Q → LATIN CAPITAL LETTER Q#
    {codepoint = 119982, with = "S"},   -- MA# ( 𝒮 → S ) MATHEMATICAL SCRIPT CAPITAL S → LATIN CAPITAL LETTER S#
    {codepoint = 119983, with = "T"},   -- MA# ( 𝒯 → T ) MATHEMATICAL SCRIPT CAPITAL T → LATIN CAPITAL LETTER T#
    {codepoint = 119984, with = "U"},   -- MA# ( 𝒰 → U ) MATHEMATICAL SCRIPT CAPITAL U → LATIN CAPITAL LETTER U#
    {codepoint = 119985, with = "V"},   -- MA# ( 𝒱 → V ) MATHEMATICAL SCRIPT CAPITAL V → LATIN CAPITAL LETTER V#
    {codepoint = 119986, with = "W"},   -- MA# ( 𝒲 → W ) MATHEMATICAL SCRIPT CAPITAL W → LATIN CAPITAL LETTER W#
    {codepoint = 119987, with = "X"},   -- MA# ( 𝒳 → X ) MATHEMATICAL SCRIPT CAPITAL X → LATIN CAPITAL LETTER X#
    {codepoint = 119988, with = "Y"},   -- MA# ( 𝒴 → Y ) MATHEMATICAL SCRIPT CAPITAL Y → LATIN CAPITAL LETTER Y#
    {codepoint = 119989, with = "Z"},   -- MA# ( 𝒵 → Z ) MATHEMATICAL SCRIPT CAPITAL Z → LATIN CAPITAL LETTER Z#
    {codepoint = 119990, with = "a"},   -- MA# ( 𝒶 → a ) MATHEMATICAL SCRIPT SMALL A → LATIN SMALL LETTER A#
    {codepoint = 119991, with = "b"},   -- MA# ( 𝒷 → b ) MATHEMATICAL SCRIPT SMALL B → LATIN SMALL LETTER B#
    {codepoint = 119992, with = "c"},   -- MA# ( 𝒸 → c ) MATHEMATICAL SCRIPT SMALL C → LATIN SMALL LETTER C#
    {codepoint = 119993, with = "d"},   -- MA# ( 𝒹 → d ) MATHEMATICAL SCRIPT SMALL D → LATIN SMALL LETTER D#
    {codepoint = 119995, with = "f"},   -- MA# ( 𝒻 → f ) MATHEMATICAL SCRIPT SMALL F → LATIN SMALL LETTER F#
    {codepoint = 119997, with = "h"},   -- MA# ( 𝒽 → h ) MATHEMATICAL SCRIPT SMALL H → LATIN SMALL LETTER H#
    {codepoint = 119998, with = "i"},   -- MA# ( 𝒾 → i ) MATHEMATICAL SCRIPT SMALL I → LATIN SMALL LETTER I#
    {codepoint = 119999, with = "j"},   -- MA# ( 𝒿 → j ) MATHEMATICAL SCRIPT SMALL J → LATIN SMALL LETTER J#
    {codepoint = 120000, with = "k"},   -- MA# ( 𝓀 → k ) MATHEMATICAL SCRIPT SMALL K → LATIN SMALL LETTER K#
    {codepoint = 120001, with = "l"},   -- MA# ( 𝓁 → l ) MATHEMATICAL SCRIPT SMALL L → LATIN SMALL LETTER L#
    {codepoint = 120002, with = "rn"},  -- MA# ( 𝓂 → rn ) MATHEMATICAL SCRIPT SMALL M → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 120003, with = "n"},   -- MA# ( 𝓃 → n ) MATHEMATICAL SCRIPT SMALL N → LATIN SMALL LETTER N#
    {codepoint = 120005, with = "p"},   -- MA# ( 𝓅 → p ) MATHEMATICAL SCRIPT SMALL P → LATIN SMALL LETTER P#
    {codepoint = 120006, with = "q"},   -- MA# ( 𝓆 → q ) MATHEMATICAL SCRIPT SMALL Q → LATIN SMALL LETTER Q#
    {codepoint = 120007, with = "r"},   -- MA# ( 𝓇 → r ) MATHEMATICAL SCRIPT SMALL R → LATIN SMALL LETTER R#
    {codepoint = 120008, with = "s"},   -- MA# ( 𝓈 → s ) MATHEMATICAL SCRIPT SMALL S → LATIN SMALL LETTER S#
    {codepoint = 120009, with = "t"},   -- MA# ( 𝓉 → t ) MATHEMATICAL SCRIPT SMALL T → LATIN SMALL LETTER T#
    {codepoint = 120010, with = "u"},   -- MA# ( 𝓊 → u ) MATHEMATICAL SCRIPT SMALL U → LATIN SMALL LETTER U#
    {codepoint = 120011, with = "v"},   -- MA# ( 𝓋 → v ) MATHEMATICAL SCRIPT SMALL V → LATIN SMALL LETTER V#
    {codepoint = 120012, with = "w"},   -- MA# ( 𝓌 → w ) MATHEMATICAL SCRIPT SMALL W → LATIN SMALL LETTER W#
    {codepoint = 120013, with = "x"},   -- MA# ( 𝓍 → x ) MATHEMATICAL SCRIPT SMALL X → LATIN SMALL LETTER X#
    {codepoint = 120014, with = "y"},   -- MA# ( 𝓎 → y ) MATHEMATICAL SCRIPT SMALL Y → LATIN SMALL LETTER Y#
    {codepoint = 120015, with = "z"},   -- MA# ( 𝓏 → z ) MATHEMATICAL SCRIPT SMALL Z → LATIN SMALL LETTER Z#
    {codepoint = 120016, with = "A"},   -- MA# ( 𝓐 → A ) MATHEMATICAL BOLD SCRIPT CAPITAL A → LATIN CAPITAL LETTER A#
    {codepoint = 120017, with = "B"},   -- MA# ( 𝓑 → B ) MATHEMATICAL BOLD SCRIPT CAPITAL B → LATIN CAPITAL LETTER B#
    {codepoint = 120018, with = "C"},   -- MA# ( 𝓒 → C ) MATHEMATICAL BOLD SCRIPT CAPITAL C → LATIN CAPITAL LETTER C#
    {codepoint = 120019, with = "D"},   -- MA# ( 𝓓 → D ) MATHEMATICAL BOLD SCRIPT CAPITAL D → LATIN CAPITAL LETTER D#
    {codepoint = 120020, with = "E"},   -- MA# ( 𝓔 → E ) MATHEMATICAL BOLD SCRIPT CAPITAL E → LATIN CAPITAL LETTER E#
    {codepoint = 120021, with = "F"},   -- MA# ( 𝓕 → F ) MATHEMATICAL BOLD SCRIPT CAPITAL F → LATIN CAPITAL LETTER F#
    {codepoint = 120022, with = "G"},   -- MA# ( 𝓖 → G ) MATHEMATICAL BOLD SCRIPT CAPITAL G → LATIN CAPITAL LETTER G#
    {codepoint = 120023, with = "H"},   -- MA# ( 𝓗 → H ) MATHEMATICAL BOLD SCRIPT CAPITAL H → LATIN CAPITAL LETTER H#
    {codepoint = 120024, with = "l"},   -- MA# ( 𝓘 → l ) MATHEMATICAL BOLD SCRIPT CAPITAL I → LATIN SMALL LETTER L# →I→
    {codepoint = 120025, with = "J"},   -- MA# ( 𝓙 → J ) MATHEMATICAL BOLD SCRIPT CAPITAL J → LATIN CAPITAL LETTER J#
    {codepoint = 120026, with = "K"},   -- MA# ( 𝓚 → K ) MATHEMATICAL BOLD SCRIPT CAPITAL K → LATIN CAPITAL LETTER K#
    {codepoint = 120027, with = "L"},   -- MA# ( 𝓛 → L ) MATHEMATICAL BOLD SCRIPT CAPITAL L → LATIN CAPITAL LETTER L#
    {codepoint = 120028, with = "M"},   -- MA# ( 𝓜 → M ) MATHEMATICAL BOLD SCRIPT CAPITAL M → LATIN CAPITAL LETTER M#
    {codepoint = 120029, with = "N"},   -- MA# ( 𝓝 → N ) MATHEMATICAL BOLD SCRIPT CAPITAL N → LATIN CAPITAL LETTER N#
    {codepoint = 120030, with = "O"},   -- MA# ( 𝓞 → O ) MATHEMATICAL BOLD SCRIPT CAPITAL O → LATIN CAPITAL LETTER O#
    {codepoint = 120031, with = "P"},   -- MA# ( 𝓟 → P ) MATHEMATICAL BOLD SCRIPT CAPITAL P → LATIN CAPITAL LETTER P#
    {codepoint = 120032, with = "Q"},   -- MA# ( 𝓠 → Q ) MATHEMATICAL BOLD SCRIPT CAPITAL Q → LATIN CAPITAL LETTER Q#
    {codepoint = 120033, with = "R"},   -- MA# ( 𝓡 → R ) MATHEMATICAL BOLD SCRIPT CAPITAL R → LATIN CAPITAL LETTER R#
    {codepoint = 120034, with = "S"},   -- MA# ( 𝓢 → S ) MATHEMATICAL BOLD SCRIPT CAPITAL S → LATIN CAPITAL LETTER S#
    {codepoint = 120035, with = "T"},   -- MA# ( 𝓣 → T ) MATHEMATICAL BOLD SCRIPT CAPITAL T → LATIN CAPITAL LETTER T#
    {codepoint = 120036, with = "U"},   -- MA# ( 𝓤 → U ) MATHEMATICAL BOLD SCRIPT CAPITAL U → LATIN CAPITAL LETTER U#
    {codepoint = 120037, with = "V"},   -- MA# ( 𝓥 → V ) MATHEMATICAL BOLD SCRIPT CAPITAL V → LATIN CAPITAL LETTER V#
    {codepoint = 120038, with = "W"},   -- MA# ( 𝓦 → W ) MATHEMATICAL BOLD SCRIPT CAPITAL W → LATIN CAPITAL LETTER W#
    {codepoint = 120039, with = "X"},   -- MA# ( 𝓧 → X ) MATHEMATICAL BOLD SCRIPT CAPITAL X → LATIN CAPITAL LETTER X#
    {codepoint = 120040, with = "Y"},   -- MA# ( 𝓨 → Y ) MATHEMATICAL BOLD SCRIPT CAPITAL Y → LATIN CAPITAL LETTER Y#
    {codepoint = 120041, with = "Z"},   -- MA# ( 𝓩 → Z ) MATHEMATICAL BOLD SCRIPT CAPITAL Z → LATIN CAPITAL LETTER Z#
    {codepoint = 120042, with = "a"},   -- MA# ( 𝓪 → a ) MATHEMATICAL BOLD SCRIPT SMALL A → LATIN SMALL LETTER A#
    {codepoint = 120043, with = "b"},   -- MA# ( 𝓫 → b ) MATHEMATICAL BOLD SCRIPT SMALL B → LATIN SMALL LETTER B#
    {codepoint = 120044, with = "c"},   -- MA# ( 𝓬 → c ) MATHEMATICAL BOLD SCRIPT SMALL C → LATIN SMALL LETTER C#
    {codepoint = 120045, with = "d"},   -- MA# ( 𝓭 → d ) MATHEMATICAL BOLD SCRIPT SMALL D → LATIN SMALL LETTER D#
    {codepoint = 120046, with = "e"},   -- MA# ( 𝓮 → e ) MATHEMATICAL BOLD SCRIPT SMALL E → LATIN SMALL LETTER E#
    {codepoint = 120047, with = "f"},   -- MA# ( 𝓯 → f ) MATHEMATICAL BOLD SCRIPT SMALL F → LATIN SMALL LETTER F#
    {codepoint = 120048, with = "g"},   -- MA# ( 𝓰 → g ) MATHEMATICAL BOLD SCRIPT SMALL G → LATIN SMALL LETTER G#
    {codepoint = 120049, with = "h"},   -- MA# ( 𝓱 → h ) MATHEMATICAL BOLD SCRIPT SMALL H → LATIN SMALL LETTER H#
    {codepoint = 120050, with = "i"},   -- MA# ( 𝓲 → i ) MATHEMATICAL BOLD SCRIPT SMALL I → LATIN SMALL LETTER I#
    {codepoint = 120051, with = "j"},   -- MA# ( 𝓳 → j ) MATHEMATICAL BOLD SCRIPT SMALL J → LATIN SMALL LETTER J#
    {codepoint = 120052, with = "k"},   -- MA# ( 𝓴 → k ) MATHEMATICAL BOLD SCRIPT SMALL K → LATIN SMALL LETTER K#
    {codepoint = 120053, with = "l"},   -- MA# ( 𝓵 → l ) MATHEMATICAL BOLD SCRIPT SMALL L → LATIN SMALL LETTER L#
    {codepoint = 120054, with = "rn"},  -- MA# ( 𝓶 → rn ) MATHEMATICAL BOLD SCRIPT SMALL M → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 120055, with = "n"},   -- MA# ( 𝓷 → n ) MATHEMATICAL BOLD SCRIPT SMALL N → LATIN SMALL LETTER N#
    {codepoint = 120056, with = "o"},   -- MA# ( 𝓸 → o ) MATHEMATICAL BOLD SCRIPT SMALL O → LATIN SMALL LETTER O#
    {codepoint = 120057, with = "p"},   -- MA# ( 𝓹 → p ) MATHEMATICAL BOLD SCRIPT SMALL P → LATIN SMALL LETTER P#
    {codepoint = 120058, with = "q"},   -- MA# ( 𝓺 → q ) MATHEMATICAL BOLD SCRIPT SMALL Q → LATIN SMALL LETTER Q#
    {codepoint = 120059, with = "r"},   -- MA# ( 𝓻 → r ) MATHEMATICAL BOLD SCRIPT SMALL R → LATIN SMALL LETTER R#
    {codepoint = 120060, with = "s"},   -- MA# ( 𝓼 → s ) MATHEMATICAL BOLD SCRIPT SMALL S → LATIN SMALL LETTER S#
    {codepoint = 120061, with = "t"},   -- MA# ( 𝓽 → t ) MATHEMATICAL BOLD SCRIPT SMALL T → LATIN SMALL LETTER T#
    {codepoint = 120062, with = "u"},   -- MA# ( 𝓾 → u ) MATHEMATICAL BOLD SCRIPT SMALL U → LATIN SMALL LETTER U#
    {codepoint = 120063, with = "v"},   -- MA# ( 𝓿 → v ) MATHEMATICAL BOLD SCRIPT SMALL V → LATIN SMALL LETTER V#
    {codepoint = 120064, with = "w"},   -- MA# ( 𝔀 → w ) MATHEMATICAL BOLD SCRIPT SMALL W → LATIN SMALL LETTER W#
    {codepoint = 120065, with = "x"},   -- MA# ( 𝔁 → x ) MATHEMATICAL BOLD SCRIPT SMALL X → LATIN SMALL LETTER X#
    {codepoint = 120066, with = "y"},   -- MA# ( 𝔂 → y ) MATHEMATICAL BOLD SCRIPT SMALL Y → LATIN SMALL LETTER Y#
    {codepoint = 120067, with = "z"},   -- MA# ( 𝔃 → z ) MATHEMATICAL BOLD SCRIPT SMALL Z → LATIN SMALL LETTER Z#
    {codepoint = 120068, with = "A"},   -- MA# ( 𝔄 → A ) MATHEMATICAL FRAKTUR CAPITAL A → LATIN CAPITAL LETTER A#
    {codepoint = 120069, with = "B"},   -- MA# ( 𝔅 → B ) MATHEMATICAL FRAKTUR CAPITAL B → LATIN CAPITAL LETTER B#
    {codepoint = 120071, with = "D"},   -- MA# ( 𝔇 → D ) MATHEMATICAL FRAKTUR CAPITAL D → LATIN CAPITAL LETTER D#
    {codepoint = 120072, with = "E"},   -- MA# ( 𝔈 → E ) MATHEMATICAL FRAKTUR CAPITAL E → LATIN CAPITAL LETTER E#
    {codepoint = 120073, with = "F"},   -- MA# ( 𝔉 → F ) MATHEMATICAL FRAKTUR CAPITAL F → LATIN CAPITAL LETTER F#
    {codepoint = 120074, with = "G"},   -- MA# ( 𝔊 → G ) MATHEMATICAL FRAKTUR CAPITAL G → LATIN CAPITAL LETTER G#
    {codepoint = 120077, with = "J"},   -- MA# ( 𝔍 → J ) MATHEMATICAL FRAKTUR CAPITAL J → LATIN CAPITAL LETTER J#
    {codepoint = 120078, with = "K"},   -- MA# ( 𝔎 → K ) MATHEMATICAL FRAKTUR CAPITAL K → LATIN CAPITAL LETTER K#
    {codepoint = 120079, with = "L"},   -- MA# ( 𝔏 → L ) MATHEMATICAL FRAKTUR CAPITAL L → LATIN CAPITAL LETTER L#
    {codepoint = 120080, with = "M"},   -- MA# ( 𝔐 → M ) MATHEMATICAL FRAKTUR CAPITAL M → LATIN CAPITAL LETTER M#
    {codepoint = 120081, with = "N"},   -- MA# ( 𝔑 → N ) MATHEMATICAL FRAKTUR CAPITAL N → LATIN CAPITAL LETTER N#
    {codepoint = 120082, with = "O"},   -- MA# ( 𝔒 → O ) MATHEMATICAL FRAKTUR CAPITAL O → LATIN CAPITAL LETTER O#
    {codepoint = 120083, with = "P"},   -- MA# ( 𝔓 → P ) MATHEMATICAL FRAKTUR CAPITAL P → LATIN CAPITAL LETTER P#
    {codepoint = 120084, with = "Q"},   -- MA# ( 𝔔 → Q ) MATHEMATICAL FRAKTUR CAPITAL Q → LATIN CAPITAL LETTER Q#
    {codepoint = 120086, with = "S"},   -- MA# ( 𝔖 → S ) MATHEMATICAL FRAKTUR CAPITAL S → LATIN CAPITAL LETTER S#
    {codepoint = 120087, with = "T"},   -- MA# ( 𝔗 → T ) MATHEMATICAL FRAKTUR CAPITAL T → LATIN CAPITAL LETTER T#
    {codepoint = 120088, with = "U"},   -- MA# ( 𝔘 → U ) MATHEMATICAL FRAKTUR CAPITAL U → LATIN CAPITAL LETTER U#
    {codepoint = 120089, with = "V"},   -- MA# ( 𝔙 → V ) MATHEMATICAL FRAKTUR CAPITAL V → LATIN CAPITAL LETTER V#
    {codepoint = 120090, with = "W"},   -- MA# ( 𝔚 → W ) MATHEMATICAL FRAKTUR CAPITAL W → LATIN CAPITAL LETTER W#
    {codepoint = 120091, with = "X"},   -- MA# ( 𝔛 → X ) MATHEMATICAL FRAKTUR CAPITAL X → LATIN CAPITAL LETTER X#
    {codepoint = 120092, with = "Y"},   -- MA# ( 𝔜 → Y ) MATHEMATICAL FRAKTUR CAPITAL Y → LATIN CAPITAL LETTER Y#
    {codepoint = 120094, with = "a"},   -- MA# ( 𝔞 → a ) MATHEMATICAL FRAKTUR SMALL A → LATIN SMALL LETTER A#
    {codepoint = 120095, with = "b"},   -- MA# ( 𝔟 → b ) MATHEMATICAL FRAKTUR SMALL B → LATIN SMALL LETTER B#
    {codepoint = 120096, with = "c"},   -- MA# ( 𝔠 → c ) MATHEMATICAL FRAKTUR SMALL C → LATIN SMALL LETTER C#
    {codepoint = 120097, with = "d"},   -- MA# ( 𝔡 → d ) MATHEMATICAL FRAKTUR SMALL D → LATIN SMALL LETTER D#
    {codepoint = 120098, with = "e"},   -- MA# ( 𝔢 → e ) MATHEMATICAL FRAKTUR SMALL E → LATIN SMALL LETTER E#
    {codepoint = 120099, with = "f"},   -- MA# ( 𝔣 → f ) MATHEMATICAL FRAKTUR SMALL F → LATIN SMALL LETTER F#
    {codepoint = 120100, with = "g"},   -- MA# ( 𝔤 → g ) MATHEMATICAL FRAKTUR SMALL G → LATIN SMALL LETTER G#
    {codepoint = 120101, with = "h"},   -- MA# ( 𝔥 → h ) MATHEMATICAL FRAKTUR SMALL H → LATIN SMALL LETTER H#
    {codepoint = 120102, with = "i"},   -- MA# ( 𝔦 → i ) MATHEMATICAL FRAKTUR SMALL I → LATIN SMALL LETTER I#
    {codepoint = 120103, with = "j"},   -- MA# ( 𝔧 → j ) MATHEMATICAL FRAKTUR SMALL J → LATIN SMALL LETTER J#
    {codepoint = 120104, with = "k"},   -- MA# ( 𝔨 → k ) MATHEMATICAL FRAKTUR SMALL K → LATIN SMALL LETTER K#
    {codepoint = 120105, with = "l"},   -- MA# ( 𝔩 → l ) MATHEMATICAL FRAKTUR SMALL L → LATIN SMALL LETTER L#
    {codepoint = 120106, with = "rn"},  -- MA# ( 𝔪 → rn ) MATHEMATICAL FRAKTUR SMALL M → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 120107, with = "n"},   -- MA# ( 𝔫 → n ) MATHEMATICAL FRAKTUR SMALL N → LATIN SMALL LETTER N#
    {codepoint = 120108, with = "o"},   -- MA# ( 𝔬 → o ) MATHEMATICAL FRAKTUR SMALL O → LATIN SMALL LETTER O#
    {codepoint = 120109, with = "p"},   -- MA# ( 𝔭 → p ) MATHEMATICAL FRAKTUR SMALL P → LATIN SMALL LETTER P#
    {codepoint = 120110, with = "q"},   -- MA# ( 𝔮 → q ) MATHEMATICAL FRAKTUR SMALL Q → LATIN SMALL LETTER Q#
    {codepoint = 120111, with = "r"},   -- MA# ( 𝔯 → r ) MATHEMATICAL FRAKTUR SMALL R → LATIN SMALL LETTER R#
    {codepoint = 120112, with = "s"},   -- MA# ( 𝔰 → s ) MATHEMATICAL FRAKTUR SMALL S → LATIN SMALL LETTER S#
    {codepoint = 120113, with = "t"},   -- MA# ( 𝔱 → t ) MATHEMATICAL FRAKTUR SMALL T → LATIN SMALL LETTER T#
    {codepoint = 120114, with = "u"},   -- MA# ( 𝔲 → u ) MATHEMATICAL FRAKTUR SMALL U → LATIN SMALL LETTER U#
    {codepoint = 120115, with = "v"},   -- MA# ( 𝔳 → v ) MATHEMATICAL FRAKTUR SMALL V → LATIN SMALL LETTER V#
    {codepoint = 120116, with = "w"},   -- MA# ( 𝔴 → w ) MATHEMATICAL FRAKTUR SMALL W → LATIN SMALL LETTER W#
    {codepoint = 120117, with = "x"},   -- MA# ( 𝔵 → x ) MATHEMATICAL FRAKTUR SMALL X → LATIN SMALL LETTER X#
    {codepoint = 120118, with = "y"},   -- MA# ( 𝔶 → y ) MATHEMATICAL FRAKTUR SMALL Y → LATIN SMALL LETTER Y#
    {codepoint = 120119, with = "z"},   -- MA# ( 𝔷 → z ) MATHEMATICAL FRAKTUR SMALL Z → LATIN SMALL LETTER Z#
    {codepoint = 120120, with = "A"},   -- MA# ( 𝔸 → A ) MATHEMATICAL DOUBLE-STRUCK CAPITAL A → LATIN CAPITAL LETTER A#
    {codepoint = 120121, with = "B"},   -- MA# ( 𝔹 → B ) MATHEMATICAL DOUBLE-STRUCK CAPITAL B → LATIN CAPITAL LETTER B#
    {codepoint = 120123, with = "D"},   -- MA# ( 𝔻 → D ) MATHEMATICAL DOUBLE-STRUCK CAPITAL D → LATIN CAPITAL LETTER D#
    {codepoint = 120124, with = "E"},   -- MA# ( 𝔼 → E ) MATHEMATICAL DOUBLE-STRUCK CAPITAL E → LATIN CAPITAL LETTER E#
    {codepoint = 120125, with = "F"},   -- MA# ( 𝔽 → F ) MATHEMATICAL DOUBLE-STRUCK CAPITAL F → LATIN CAPITAL LETTER F#
    {codepoint = 120126, with = "G"},   -- MA# ( 𝔾 → G ) MATHEMATICAL DOUBLE-STRUCK CAPITAL G → LATIN CAPITAL LETTER G#
    {codepoint = 120128, with = "l"},   -- MA# ( 𝕀 → l ) MATHEMATICAL DOUBLE-STRUCK CAPITAL I → LATIN SMALL LETTER L# →I→
    {codepoint = 120129, with = "J"},   -- MA# ( 𝕁 → J ) MATHEMATICAL DOUBLE-STRUCK CAPITAL J → LATIN CAPITAL LETTER J#
    {codepoint = 120130, with = "K"},   -- MA# ( 𝕂 → K ) MATHEMATICAL DOUBLE-STRUCK CAPITAL K → LATIN CAPITAL LETTER K#
    {codepoint = 120131, with = "L"},   -- MA# ( 𝕃 → L ) MATHEMATICAL DOUBLE-STRUCK CAPITAL L → LATIN CAPITAL LETTER L#
    {codepoint = 120132, with = "M"},   -- MA# ( 𝕄 → M ) MATHEMATICAL DOUBLE-STRUCK CAPITAL M → LATIN CAPITAL LETTER M#
    {codepoint = 120134, with = "O"},   -- MA# ( 𝕆 → O ) MATHEMATICAL DOUBLE-STRUCK CAPITAL O → LATIN CAPITAL LETTER O#
    {codepoint = 120138, with = "S"},   -- MA# ( 𝕊 → S ) MATHEMATICAL DOUBLE-STRUCK CAPITAL S → LATIN CAPITAL LETTER S#
    {codepoint = 120139, with = "T"},   -- MA# ( 𝕋 → T ) MATHEMATICAL DOUBLE-STRUCK CAPITAL T → LATIN CAPITAL LETTER T#
    {codepoint = 120140, with = "U"},   -- MA# ( 𝕌 → U ) MATHEMATICAL DOUBLE-STRUCK CAPITAL U → LATIN CAPITAL LETTER U#
    {codepoint = 120141, with = "V"},   -- MA# ( 𝕍 → V ) MATHEMATICAL DOUBLE-STRUCK CAPITAL V → LATIN CAPITAL LETTER V#
    {codepoint = 120142, with = "W"},   -- MA# ( 𝕎 → W ) MATHEMATICAL DOUBLE-STRUCK CAPITAL W → LATIN CAPITAL LETTER W#
    {codepoint = 120143, with = "X"},   -- MA# ( 𝕏 → X ) MATHEMATICAL DOUBLE-STRUCK CAPITAL X → LATIN CAPITAL LETTER X#
    {codepoint = 120144, with = "Y"},   -- MA# ( 𝕐 → Y ) MATHEMATICAL DOUBLE-STRUCK CAPITAL Y → LATIN CAPITAL LETTER Y#
    {codepoint = 120146, with = "a"},   -- MA# ( 𝕒 → a ) MATHEMATICAL DOUBLE-STRUCK SMALL A → LATIN SMALL LETTER A#
    {codepoint = 120147, with = "b"},   -- MA# ( 𝕓 → b ) MATHEMATICAL DOUBLE-STRUCK SMALL B → LATIN SMALL LETTER B#
    {codepoint = 120148, with = "c"},   -- MA# ( 𝕔 → c ) MATHEMATICAL DOUBLE-STRUCK SMALL C → LATIN SMALL LETTER C#
    {codepoint = 120149, with = "d"},   -- MA# ( 𝕕 → d ) MATHEMATICAL DOUBLE-STRUCK SMALL D → LATIN SMALL LETTER D#
    {codepoint = 120150, with = "e"},   -- MA# ( 𝕖 → e ) MATHEMATICAL DOUBLE-STRUCK SMALL E → LATIN SMALL LETTER E#
    {codepoint = 120151, with = "f"},   -- MA# ( 𝕗 → f ) MATHEMATICAL DOUBLE-STRUCK SMALL F → LATIN SMALL LETTER F#
    {codepoint = 120152, with = "g"},   -- MA# ( 𝕘 → g ) MATHEMATICAL DOUBLE-STRUCK SMALL G → LATIN SMALL LETTER G#
    {codepoint = 120153, with = "h"},   -- MA# ( 𝕙 → h ) MATHEMATICAL DOUBLE-STRUCK SMALL H → LATIN SMALL LETTER H#
    {codepoint = 120154, with = "i"},   -- MA# ( 𝕚 → i ) MATHEMATICAL DOUBLE-STRUCK SMALL I → LATIN SMALL LETTER I#
    {codepoint = 120155, with = "j"},   -- MA# ( 𝕛 → j ) MATHEMATICAL DOUBLE-STRUCK SMALL J → LATIN SMALL LETTER J#
    {codepoint = 120156, with = "k"},   -- MA# ( 𝕜 → k ) MATHEMATICAL DOUBLE-STRUCK SMALL K → LATIN SMALL LETTER K#
    {codepoint = 120157, with = "l"},   -- MA# ( 𝕝 → l ) MATHEMATICAL DOUBLE-STRUCK SMALL L → LATIN SMALL LETTER L#
    {codepoint = 120158, with = "rn"},  -- MA# ( 𝕞 → rn ) MATHEMATICAL DOUBLE-STRUCK SMALL M → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 120159, with = "n"},   -- MA# ( 𝕟 → n ) MATHEMATICAL DOUBLE-STRUCK SMALL N → LATIN SMALL LETTER N#
    {codepoint = 120160, with = "o"},   -- MA# ( 𝕠 → o ) MATHEMATICAL DOUBLE-STRUCK SMALL O → LATIN SMALL LETTER O#
    {codepoint = 120161, with = "p"},   -- MA# ( 𝕡 → p ) MATHEMATICAL DOUBLE-STRUCK SMALL P → LATIN SMALL LETTER P#
    {codepoint = 120162, with = "q"},   -- MA# ( 𝕢 → q ) MATHEMATICAL DOUBLE-STRUCK SMALL Q → LATIN SMALL LETTER Q#
    {codepoint = 120163, with = "r"},   -- MA# ( 𝕣 → r ) MATHEMATICAL DOUBLE-STRUCK SMALL R → LATIN SMALL LETTER R#
    {codepoint = 120164, with = "s"},   -- MA# ( 𝕤 → s ) MATHEMATICAL DOUBLE-STRUCK SMALL S → LATIN SMALL LETTER S#
    {codepoint = 120165, with = "t"},   -- MA# ( 𝕥 → t ) MATHEMATICAL DOUBLE-STRUCK SMALL T → LATIN SMALL LETTER T#
    {codepoint = 120166, with = "u"},   -- MA# ( 𝕦 → u ) MATHEMATICAL DOUBLE-STRUCK SMALL U → LATIN SMALL LETTER U#
    {codepoint = 120167, with = "v"},   -- MA# ( 𝕧 → v ) MATHEMATICAL DOUBLE-STRUCK SMALL V → LATIN SMALL LETTER V#
    {codepoint = 120168, with = "w"},   -- MA# ( 𝕨 → w ) MATHEMATICAL DOUBLE-STRUCK SMALL W → LATIN SMALL LETTER W#
    {codepoint = 120169, with = "x"},   -- MA# ( 𝕩 → x ) MATHEMATICAL DOUBLE-STRUCK SMALL X → LATIN SMALL LETTER X#
    {codepoint = 120170, with = "y"},   -- MA# ( 𝕪 → y ) MATHEMATICAL DOUBLE-STRUCK SMALL Y → LATIN SMALL LETTER Y#
    {codepoint = 120171, with = "z"},   -- MA# ( 𝕫 → z ) MATHEMATICAL DOUBLE-STRUCK SMALL Z → LATIN SMALL LETTER Z#
    {codepoint = 120172, with = "A"},   -- MA# ( 𝕬 → A ) MATHEMATICAL BOLD FRAKTUR CAPITAL A → LATIN CAPITAL LETTER A#
    {codepoint = 120173, with = "B"},   -- MA# ( 𝕭 → B ) MATHEMATICAL BOLD FRAKTUR CAPITAL B → LATIN CAPITAL LETTER B#
    {codepoint = 120174, with = "C"},   -- MA# ( 𝕮 → C ) MATHEMATICAL BOLD FRAKTUR CAPITAL C → LATIN CAPITAL LETTER C#
    {codepoint = 120175, with = "D"},   -- MA# ( 𝕯 → D ) MATHEMATICAL BOLD FRAKTUR CAPITAL D → LATIN CAPITAL LETTER D#
    {codepoint = 120176, with = "E"},   -- MA# ( 𝕰 → E ) MATHEMATICAL BOLD FRAKTUR CAPITAL E → LATIN CAPITAL LETTER E#
    {codepoint = 120177, with = "F"},   -- MA# ( 𝕱 → F ) MATHEMATICAL BOLD FRAKTUR CAPITAL F → LATIN CAPITAL LETTER F#
    {codepoint = 120178, with = "G"},   -- MA# ( 𝕲 → G ) MATHEMATICAL BOLD FRAKTUR CAPITAL G → LATIN CAPITAL LETTER G#
    {codepoint = 120179, with = "H"},   -- MA# ( 𝕳 → H ) MATHEMATICAL BOLD FRAKTUR CAPITAL H → LATIN CAPITAL LETTER H#
    {codepoint = 120180, with = "l"},   -- MA# ( 𝕴 → l ) MATHEMATICAL BOLD FRAKTUR CAPITAL I → LATIN SMALL LETTER L# →I→
    {codepoint = 120181, with = "J"},   -- MA# ( 𝕵 → J ) MATHEMATICAL BOLD FRAKTUR CAPITAL J → LATIN CAPITAL LETTER J#
    {codepoint = 120182, with = "K"},   -- MA# ( 𝕶 → K ) MATHEMATICAL BOLD FRAKTUR CAPITAL K → LATIN CAPITAL LETTER K#
    {codepoint = 120183, with = "L"},   -- MA# ( 𝕷 → L ) MATHEMATICAL BOLD FRAKTUR CAPITAL L → LATIN CAPITAL LETTER L#
    {codepoint = 120184, with = "M"},   -- MA# ( 𝕸 → M ) MATHEMATICAL BOLD FRAKTUR CAPITAL M → LATIN CAPITAL LETTER M#
    {codepoint = 120185, with = "N"},   -- MA# ( 𝕹 → N ) MATHEMATICAL BOLD FRAKTUR CAPITAL N → LATIN CAPITAL LETTER N#
    {codepoint = 120186, with = "O"},   -- MA# ( 𝕺 → O ) MATHEMATICAL BOLD FRAKTUR CAPITAL O → LATIN CAPITAL LETTER O#
    {codepoint = 120187, with = "P"},   -- MA# ( 𝕻 → P ) MATHEMATICAL BOLD FRAKTUR CAPITAL P → LATIN CAPITAL LETTER P#
    {codepoint = 120188, with = "Q"},   -- MA# ( 𝕼 → Q ) MATHEMATICAL BOLD FRAKTUR CAPITAL Q → LATIN CAPITAL LETTER Q#
    {codepoint = 120189, with = "R"},   -- MA# ( 𝕽 → R ) MATHEMATICAL BOLD FRAKTUR CAPITAL R → LATIN CAPITAL LETTER R#
    {codepoint = 120190, with = "S"},   -- MA# ( 𝕾 → S ) MATHEMATICAL BOLD FRAKTUR CAPITAL S → LATIN CAPITAL LETTER S#
    {codepoint = 120191, with = "T"},   -- MA# ( 𝕿 → T ) MATHEMATICAL BOLD FRAKTUR CAPITAL T → LATIN CAPITAL LETTER T#
    {codepoint = 120192, with = "U"},   -- MA# ( 𝖀 → U ) MATHEMATICAL BOLD FRAKTUR CAPITAL U → LATIN CAPITAL LETTER U#
    {codepoint = 120193, with = "V"},   -- MA# ( 𝖁 → V ) MATHEMATICAL BOLD FRAKTUR CAPITAL V → LATIN CAPITAL LETTER V#
    {codepoint = 120194, with = "W"},   -- MA# ( 𝖂 → W ) MATHEMATICAL BOLD FRAKTUR CAPITAL W → LATIN CAPITAL LETTER W#
    {codepoint = 120195, with = "X"},   -- MA# ( 𝖃 → X ) MATHEMATICAL BOLD FRAKTUR CAPITAL X → LATIN CAPITAL LETTER X#
    {codepoint = 120196, with = "Y"},   -- MA# ( 𝖄 → Y ) MATHEMATICAL BOLD FRAKTUR CAPITAL Y → LATIN CAPITAL LETTER Y#
    {codepoint = 120197, with = "Z"},   -- MA# ( 𝖅 → Z ) MATHEMATICAL BOLD FRAKTUR CAPITAL Z → LATIN CAPITAL LETTER Z#
    {codepoint = 120198, with = "a"},   -- MA# ( 𝖆 → a ) MATHEMATICAL BOLD FRAKTUR SMALL A → LATIN SMALL LETTER A#
    {codepoint = 120199, with = "b"},   -- MA# ( 𝖇 → b ) MATHEMATICAL BOLD FRAKTUR SMALL B → LATIN SMALL LETTER B#
    {codepoint = 120200, with = "c"},   -- MA# ( 𝖈 → c ) MATHEMATICAL BOLD FRAKTUR SMALL C → LATIN SMALL LETTER C#
    {codepoint = 120201, with = "d"},   -- MA# ( 𝖉 → d ) MATHEMATICAL BOLD FRAKTUR SMALL D → LATIN SMALL LETTER D#
    {codepoint = 120202, with = "e"},   -- MA# ( 𝖊 → e ) MATHEMATICAL BOLD FRAKTUR SMALL E → LATIN SMALL LETTER E#
    {codepoint = 120203, with = "f"},   -- MA# ( 𝖋 → f ) MATHEMATICAL BOLD FRAKTUR SMALL F → LATIN SMALL LETTER F#
    {codepoint = 120204, with = "g"},   -- MA# ( 𝖌 → g ) MATHEMATICAL BOLD FRAKTUR SMALL G → LATIN SMALL LETTER G#
    {codepoint = 120205, with = "h"},   -- MA# ( 𝖍 → h ) MATHEMATICAL BOLD FRAKTUR SMALL H → LATIN SMALL LETTER H#
    {codepoint = 120206, with = "i"},   -- MA# ( 𝖎 → i ) MATHEMATICAL BOLD FRAKTUR SMALL I → LATIN SMALL LETTER I#
    {codepoint = 120207, with = "j"},   -- MA# ( 𝖏 → j ) MATHEMATICAL BOLD FRAKTUR SMALL J → LATIN SMALL LETTER J#
    {codepoint = 120208, with = "k"},   -- MA# ( 𝖐 → k ) MATHEMATICAL BOLD FRAKTUR SMALL K → LATIN SMALL LETTER K#
    {codepoint = 120209, with = "l"},   -- MA# ( 𝖑 → l ) MATHEMATICAL BOLD FRAKTUR SMALL L → LATIN SMALL LETTER L#
    {codepoint = 120210, with = "rn"},  -- MA# ( 𝖒 → rn ) MATHEMATICAL BOLD FRAKTUR SMALL M → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 120211, with = "n"},   -- MA# ( 𝖓 → n ) MATHEMATICAL BOLD FRAKTUR SMALL N → LATIN SMALL LETTER N#
    {codepoint = 120212, with = "o"},   -- MA# ( 𝖔 → o ) MATHEMATICAL BOLD FRAKTUR SMALL O → LATIN SMALL LETTER O#
    {codepoint = 120213, with = "p"},   -- MA# ( 𝖕 → p ) MATHEMATICAL BOLD FRAKTUR SMALL P → LATIN SMALL LETTER P#
    {codepoint = 120214, with = "q"},   -- MA# ( 𝖖 → q ) MATHEMATICAL BOLD FRAKTUR SMALL Q → LATIN SMALL LETTER Q#
    {codepoint = 120215, with = "r"},   -- MA# ( 𝖗 → r ) MATHEMATICAL BOLD FRAKTUR SMALL R → LATIN SMALL LETTER R#
    {codepoint = 120216, with = "s"},   -- MA# ( 𝖘 → s ) MATHEMATICAL BOLD FRAKTUR SMALL S → LATIN SMALL LETTER S#
    {codepoint = 120217, with = "t"},   -- MA# ( 𝖙 → t ) MATHEMATICAL BOLD FRAKTUR SMALL T → LATIN SMALL LETTER T#
    {codepoint = 120218, with = "u"},   -- MA# ( 𝖚 → u ) MATHEMATICAL BOLD FRAKTUR SMALL U → LATIN SMALL LETTER U#
    {codepoint = 120219, with = "v"},   -- MA# ( 𝖛 → v ) MATHEMATICAL BOLD FRAKTUR SMALL V → LATIN SMALL LETTER V#
    {codepoint = 120220, with = "w"},   -- MA# ( 𝖜 → w ) MATHEMATICAL BOLD FRAKTUR SMALL W → LATIN SMALL LETTER W#
    {codepoint = 120221, with = "x"},   -- MA# ( 𝖝 → x ) MATHEMATICAL BOLD FRAKTUR SMALL X → LATIN SMALL LETTER X#
    {codepoint = 120222, with = "y"},   -- MA# ( 𝖞 → y ) MATHEMATICAL BOLD FRAKTUR SMALL Y → LATIN SMALL LETTER Y#
    {codepoint = 120223, with = "z"},   -- MA# ( 𝖟 → z ) MATHEMATICAL BOLD FRAKTUR SMALL Z → LATIN SMALL LETTER Z#
    {codepoint = 120224, with = "A"},   -- MA# ( 𝖠 → A ) MATHEMATICAL SANS-SERIF CAPITAL A → LATIN CAPITAL LETTER A#
    {codepoint = 120225, with = "B"},   -- MA# ( 𝖡 → B ) MATHEMATICAL SANS-SERIF CAPITAL B → LATIN CAPITAL LETTER B#
    {codepoint = 120226, with = "C"},   -- MA# ( 𝖢 → C ) MATHEMATICAL SANS-SERIF CAPITAL C → LATIN CAPITAL LETTER C#
    {codepoint = 120227, with = "D"},   -- MA# ( 𝖣 → D ) MATHEMATICAL SANS-SERIF CAPITAL D → LATIN CAPITAL LETTER D#
    {codepoint = 120228, with = "E"},   -- MA# ( 𝖤 → E ) MATHEMATICAL SANS-SERIF CAPITAL E → LATIN CAPITAL LETTER E#
    {codepoint = 120229, with = "F"},   -- MA# ( 𝖥 → F ) MATHEMATICAL SANS-SERIF CAPITAL F → LATIN CAPITAL LETTER F#
    {codepoint = 120230, with = "G"},   -- MA# ( 𝖦 → G ) MATHEMATICAL SANS-SERIF CAPITAL G → LATIN CAPITAL LETTER G#
    {codepoint = 120231, with = "H"},   -- MA# ( 𝖧 → H ) MATHEMATICAL SANS-SERIF CAPITAL H → LATIN CAPITAL LETTER H#
    {codepoint = 120232, with = "l"},   -- MA# ( 𝖨 → l ) MATHEMATICAL SANS-SERIF CAPITAL I → LATIN SMALL LETTER L# →I→
    {codepoint = 120233, with = "J"},   -- MA# ( 𝖩 → J ) MATHEMATICAL SANS-SERIF CAPITAL J → LATIN CAPITAL LETTER J#
    {codepoint = 120234, with = "K"},   -- MA# ( 𝖪 → K ) MATHEMATICAL SANS-SERIF CAPITAL K → LATIN CAPITAL LETTER K#
    {codepoint = 120235, with = "L"},   -- MA# ( 𝖫 → L ) MATHEMATICAL SANS-SERIF CAPITAL L → LATIN CAPITAL LETTER L#
    {codepoint = 120236, with = "M"},   -- MA# ( 𝖬 → M ) MATHEMATICAL SANS-SERIF CAPITAL M → LATIN CAPITAL LETTER M#
    {codepoint = 120237, with = "N"},   -- MA# ( 𝖭 → N ) MATHEMATICAL SANS-SERIF CAPITAL N → LATIN CAPITAL LETTER N#
    {codepoint = 120238, with = "O"},   -- MA# ( 𝖮 → O ) MATHEMATICAL SANS-SERIF CAPITAL O → LATIN CAPITAL LETTER O#
    {codepoint = 120239, with = "P"},   -- MA# ( 𝖯 → P ) MATHEMATICAL SANS-SERIF CAPITAL P → LATIN CAPITAL LETTER P#
    {codepoint = 120240, with = "Q"},   -- MA# ( 𝖰 → Q ) MATHEMATICAL SANS-SERIF CAPITAL Q → LATIN CAPITAL LETTER Q#
    {codepoint = 120241, with = "R"},   -- MA# ( 𝖱 → R ) MATHEMATICAL SANS-SERIF CAPITAL R → LATIN CAPITAL LETTER R#
    {codepoint = 120242, with = "S"},   -- MA# ( 𝖲 → S ) MATHEMATICAL SANS-SERIF CAPITAL S → LATIN CAPITAL LETTER S#
    {codepoint = 120243, with = "T"},   -- MA# ( 𝖳 → T ) MATHEMATICAL SANS-SERIF CAPITAL T → LATIN CAPITAL LETTER T#
    {codepoint = 120244, with = "U"},   -- MA# ( 𝖴 → U ) MATHEMATICAL SANS-SERIF CAPITAL U → LATIN CAPITAL LETTER U#
    {codepoint = 120245, with = "V"},   -- MA# ( 𝖵 → V ) MATHEMATICAL SANS-SERIF CAPITAL V → LATIN CAPITAL LETTER V#
    {codepoint = 120246, with = "W"},   -- MA# ( 𝖶 → W ) MATHEMATICAL SANS-SERIF CAPITAL W → LATIN CAPITAL LETTER W#
    {codepoint = 120247, with = "X"},   -- MA# ( 𝖷 → X ) MATHEMATICAL SANS-SERIF CAPITAL X → LATIN CAPITAL LETTER X#
    {codepoint = 120248, with = "Y"},   -- MA# ( 𝖸 → Y ) MATHEMATICAL SANS-SERIF CAPITAL Y → LATIN CAPITAL LETTER Y#
    {codepoint = 120249, with = "Z"},   -- MA# ( 𝖹 → Z ) MATHEMATICAL SANS-SERIF CAPITAL Z → LATIN CAPITAL LETTER Z#
    {codepoint = 120250, with = "a"},   -- MA# ( 𝖺 → a ) MATHEMATICAL SANS-SERIF SMALL A → LATIN SMALL LETTER A#
    {codepoint = 120251, with = "b"},   -- MA# ( 𝖻 → b ) MATHEMATICAL SANS-SERIF SMALL B → LATIN SMALL LETTER B#
    {codepoint = 120252, with = "c"},   -- MA# ( 𝖼 → c ) MATHEMATICAL SANS-SERIF SMALL C → LATIN SMALL LETTER C#
    {codepoint = 120253, with = "d"},   -- MA# ( 𝖽 → d ) MATHEMATICAL SANS-SERIF SMALL D → LATIN SMALL LETTER D#
    {codepoint = 120254, with = "e"},   -- MA# ( 𝖾 → e ) MATHEMATICAL SANS-SERIF SMALL E → LATIN SMALL LETTER E#
    {codepoint = 120255, with = "f"},   -- MA# ( 𝖿 → f ) MATHEMATICAL SANS-SERIF SMALL F → LATIN SMALL LETTER F#
    {codepoint = 120256, with = "g"},   -- MA# ( 𝗀 → g ) MATHEMATICAL SANS-SERIF SMALL G → LATIN SMALL LETTER G#
    {codepoint = 120257, with = "h"},   -- MA# ( 𝗁 → h ) MATHEMATICAL SANS-SERIF SMALL H → LATIN SMALL LETTER H#
    {codepoint = 120258, with = "i"},   -- MA# ( 𝗂 → i ) MATHEMATICAL SANS-SERIF SMALL I → LATIN SMALL LETTER I#
    {codepoint = 120259, with = "j"},   -- MA# ( 𝗃 → j ) MATHEMATICAL SANS-SERIF SMALL J → LATIN SMALL LETTER J#
    {codepoint = 120260, with = "k"},   -- MA# ( 𝗄 → k ) MATHEMATICAL SANS-SERIF SMALL K → LATIN SMALL LETTER K#
    {codepoint = 120261, with = "l"},   -- MA# ( 𝗅 → l ) MATHEMATICAL SANS-SERIF SMALL L → LATIN SMALL LETTER L#
    {codepoint = 120262, with = "rn"},  -- MA# ( 𝗆 → rn ) MATHEMATICAL SANS-SERIF SMALL M → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 120263, with = "n"},   -- MA# ( 𝗇 → n ) MATHEMATICAL SANS-SERIF SMALL N → LATIN SMALL LETTER N#
    {codepoint = 120264, with = "o"},   -- MA# ( 𝗈 → o ) MATHEMATICAL SANS-SERIF SMALL O → LATIN SMALL LETTER O#
    {codepoint = 120265, with = "p"},   -- MA# ( 𝗉 → p ) MATHEMATICAL SANS-SERIF SMALL P → LATIN SMALL LETTER P#
    {codepoint = 120266, with = "q"},   -- MA# ( 𝗊 → q ) MATHEMATICAL SANS-SERIF SMALL Q → LATIN SMALL LETTER Q#
    {codepoint = 120267, with = "r"},   -- MA# ( 𝗋 → r ) MATHEMATICAL SANS-SERIF SMALL R → LATIN SMALL LETTER R#
    {codepoint = 120268, with = "s"},   -- MA# ( 𝗌 → s ) MATHEMATICAL SANS-SERIF SMALL S → LATIN SMALL LETTER S#
    {codepoint = 120269, with = "t"},   -- MA# ( 𝗍 → t ) MATHEMATICAL SANS-SERIF SMALL T → LATIN SMALL LETTER T#
    {codepoint = 120270, with = "u"},   -- MA# ( 𝗎 → u ) MATHEMATICAL SANS-SERIF SMALL U → LATIN SMALL LETTER U#
    {codepoint = 120271, with = "v"},   -- MA# ( 𝗏 → v ) MATHEMATICAL SANS-SERIF SMALL V → LATIN SMALL LETTER V#
    {codepoint = 120272, with = "w"},   -- MA# ( 𝗐 → w ) MATHEMATICAL SANS-SERIF SMALL W → LATIN SMALL LETTER W#
    {codepoint = 120273, with = "x"},   -- MA# ( 𝗑 → x ) MATHEMATICAL SANS-SERIF SMALL X → LATIN SMALL LETTER X#
    {codepoint = 120274, with = "y"},   -- MA# ( 𝗒 → y ) MATHEMATICAL SANS-SERIF SMALL Y → LATIN SMALL LETTER Y#
    {codepoint = 120275, with = "z"},   -- MA# ( 𝗓 → z ) MATHEMATICAL SANS-SERIF SMALL Z → LATIN SMALL LETTER Z#
    {codepoint = 120276, with = "A"},   -- MA# ( 𝗔 → A ) MATHEMATICAL SANS-SERIF BOLD CAPITAL A → LATIN CAPITAL LETTER A#
    {codepoint = 120277, with = "B"},   -- MA# ( 𝗕 → B ) MATHEMATICAL SANS-SERIF BOLD CAPITAL B → LATIN CAPITAL LETTER B#
    {codepoint = 120278, with = "C"},   -- MA# ( 𝗖 → C ) MATHEMATICAL SANS-SERIF BOLD CAPITAL C → LATIN CAPITAL LETTER C#
    {codepoint = 120279, with = "D"},   -- MA# ( 𝗗 → D ) MATHEMATICAL SANS-SERIF BOLD CAPITAL D → LATIN CAPITAL LETTER D#
    {codepoint = 120280, with = "E"},   -- MA# ( 𝗘 → E ) MATHEMATICAL SANS-SERIF BOLD CAPITAL E → LATIN CAPITAL LETTER E#
    {codepoint = 120281, with = "F"},   -- MA# ( 𝗙 → F ) MATHEMATICAL SANS-SERIF BOLD CAPITAL F → LATIN CAPITAL LETTER F#
    {codepoint = 120282, with = "G"},   -- MA# ( 𝗚 → G ) MATHEMATICAL SANS-SERIF BOLD CAPITAL G → LATIN CAPITAL LETTER G#
    {codepoint = 120283, with = "H"},   -- MA# ( 𝗛 → H ) MATHEMATICAL SANS-SERIF BOLD CAPITAL H → LATIN CAPITAL LETTER H#
    {codepoint = 120284, with = "l"},   -- MA# ( 𝗜 → l ) MATHEMATICAL SANS-SERIF BOLD CAPITAL I → LATIN SMALL LETTER L# →I→
    {codepoint = 120285, with = "J"},   -- MA# ( 𝗝 → J ) MATHEMATICAL SANS-SERIF BOLD CAPITAL J → LATIN CAPITAL LETTER J#
    {codepoint = 120286, with = "K"},   -- MA# ( 𝗞 → K ) MATHEMATICAL SANS-SERIF BOLD CAPITAL K → LATIN CAPITAL LETTER K#
    {codepoint = 120287, with = "L"},   -- MA# ( 𝗟 → L ) MATHEMATICAL SANS-SERIF BOLD CAPITAL L → LATIN CAPITAL LETTER L#
    {codepoint = 120288, with = "M"},   -- MA# ( 𝗠 → M ) MATHEMATICAL SANS-SERIF BOLD CAPITAL M → LATIN CAPITAL LETTER M#
    {codepoint = 120289, with = "N"},   -- MA# ( 𝗡 → N ) MATHEMATICAL SANS-SERIF BOLD CAPITAL N → LATIN CAPITAL LETTER N#
    {codepoint = 120290, with = "O"},   -- MA# ( 𝗢 → O ) MATHEMATICAL SANS-SERIF BOLD CAPITAL O → LATIN CAPITAL LETTER O#
    {codepoint = 120291, with = "P"},   -- MA# ( 𝗣 → P ) MATHEMATICAL SANS-SERIF BOLD CAPITAL P → LATIN CAPITAL LETTER P#
    {codepoint = 120292, with = "Q"},   -- MA# ( 𝗤 → Q ) MATHEMATICAL SANS-SERIF BOLD CAPITAL Q → LATIN CAPITAL LETTER Q#
    {codepoint = 120293, with = "R"},   -- MA# ( 𝗥 → R ) MATHEMATICAL SANS-SERIF BOLD CAPITAL R → LATIN CAPITAL LETTER R#
    {codepoint = 120294, with = "S"},   -- MA# ( 𝗦 → S ) MATHEMATICAL SANS-SERIF BOLD CAPITAL S → LATIN CAPITAL LETTER S#
    {codepoint = 120295, with = "T"},   -- MA# ( 𝗧 → T ) MATHEMATICAL SANS-SERIF BOLD CAPITAL T → LATIN CAPITAL LETTER T#
    {codepoint = 120296, with = "U"},   -- MA# ( 𝗨 → U ) MATHEMATICAL SANS-SERIF BOLD CAPITAL U → LATIN CAPITAL LETTER U#
    {codepoint = 120297, with = "V"},   -- MA# ( 𝗩 → V ) MATHEMATICAL SANS-SERIF BOLD CAPITAL V → LATIN CAPITAL LETTER V#
    {codepoint = 120298, with = "W"},   -- MA# ( 𝗪 → W ) MATHEMATICAL SANS-SERIF BOLD CAPITAL W → LATIN CAPITAL LETTER W#
    {codepoint = 120299, with = "X"},   -- MA# ( 𝗫 → X ) MATHEMATICAL SANS-SERIF BOLD CAPITAL X → LATIN CAPITAL LETTER X#
    {codepoint = 120300, with = "Y"},   -- MA# ( 𝗬 → Y ) MATHEMATICAL SANS-SERIF BOLD CAPITAL Y → LATIN CAPITAL LETTER Y#
    {codepoint = 120301, with = "Z"},   -- MA# ( 𝗭 → Z ) MATHEMATICAL SANS-SERIF BOLD CAPITAL Z → LATIN CAPITAL LETTER Z#
    {codepoint = 120302, with = "a"},   -- MA# ( 𝗮 → a ) MATHEMATICAL SANS-SERIF BOLD SMALL A → LATIN SMALL LETTER A#
    {codepoint = 120303, with = "b"},   -- MA# ( 𝗯 → b ) MATHEMATICAL SANS-SERIF BOLD SMALL B → LATIN SMALL LETTER B#
    {codepoint = 120304, with = "c"},   -- MA# ( 𝗰 → c ) MATHEMATICAL SANS-SERIF BOLD SMALL C → LATIN SMALL LETTER C#
    {codepoint = 120305, with = "d"},   -- MA# ( 𝗱 → d ) MATHEMATICAL SANS-SERIF BOLD SMALL D → LATIN SMALL LETTER D#
    {codepoint = 120306, with = "e"},   -- MA# ( 𝗲 → e ) MATHEMATICAL SANS-SERIF BOLD SMALL E → LATIN SMALL LETTER E#
    {codepoint = 120307, with = "f"},   -- MA# ( 𝗳 → f ) MATHEMATICAL SANS-SERIF BOLD SMALL F → LATIN SMALL LETTER F#
    {codepoint = 120308, with = "g"},   -- MA# ( 𝗴 → g ) MATHEMATICAL SANS-SERIF BOLD SMALL G → LATIN SMALL LETTER G#
    {codepoint = 120309, with = "h"},   -- MA# ( 𝗵 → h ) MATHEMATICAL SANS-SERIF BOLD SMALL H → LATIN SMALL LETTER H#
    {codepoint = 120310, with = "i"},   -- MA# ( 𝗶 → i ) MATHEMATICAL SANS-SERIF BOLD SMALL I → LATIN SMALL LETTER I#
    {codepoint = 120311, with = "j"},   -- MA# ( 𝗷 → j ) MATHEMATICAL SANS-SERIF BOLD SMALL J → LATIN SMALL LETTER J#
    {codepoint = 120312, with = "k"},   -- MA# ( 𝗸 → k ) MATHEMATICAL SANS-SERIF BOLD SMALL K → LATIN SMALL LETTER K#
    {codepoint = 120313, with = "l"},   -- MA# ( 𝗹 → l ) MATHEMATICAL SANS-SERIF BOLD SMALL L → LATIN SMALL LETTER L#
    {codepoint = 120314, with = "rn"},  -- MA# ( 𝗺 → rn ) MATHEMATICAL SANS-SERIF BOLD SMALL M → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 120315, with = "n"},   -- MA# ( 𝗻 → n ) MATHEMATICAL SANS-SERIF BOLD SMALL N → LATIN SMALL LETTER N#
    {codepoint = 120316, with = "o"},   -- MA# ( 𝗼 → o ) MATHEMATICAL SANS-SERIF BOLD SMALL O → LATIN SMALL LETTER O#
    {codepoint = 120317, with = "p"},   -- MA# ( 𝗽 → p ) MATHEMATICAL SANS-SERIF BOLD SMALL P → LATIN SMALL LETTER P#
    {codepoint = 120318, with = "q"},   -- MA# ( 𝗾 → q ) MATHEMATICAL SANS-SERIF BOLD SMALL Q → LATIN SMALL LETTER Q#
    {codepoint = 120319, with = "r"},   -- MA# ( 𝗿 → r ) MATHEMATICAL SANS-SERIF BOLD SMALL R → LATIN SMALL LETTER R#
    {codepoint = 120320, with = "s"},   -- MA# ( 𝘀 → s ) MATHEMATICAL SANS-SERIF BOLD SMALL S → LATIN SMALL LETTER S#
    {codepoint = 120321, with = "t"},   -- MA# ( 𝘁 → t ) MATHEMATICAL SANS-SERIF BOLD SMALL T → LATIN SMALL LETTER T#
    {codepoint = 120322, with = "u"},   -- MA# ( 𝘂 → u ) MATHEMATICAL SANS-SERIF BOLD SMALL U → LATIN SMALL LETTER U#
    {codepoint = 120323, with = "v"},   -- MA# ( 𝘃 → v ) MATHEMATICAL SANS-SERIF BOLD SMALL V → LATIN SMALL LETTER V#
    {codepoint = 120324, with = "w"},   -- MA# ( 𝘄 → w ) MATHEMATICAL SANS-SERIF BOLD SMALL W → LATIN SMALL LETTER W#
    {codepoint = 120325, with = "x"},   -- MA# ( 𝘅 → x ) MATHEMATICAL SANS-SERIF BOLD SMALL X → LATIN SMALL LETTER X#
    {codepoint = 120326, with = "y"},   -- MA# ( 𝘆 → y ) MATHEMATICAL SANS-SERIF BOLD SMALL Y → LATIN SMALL LETTER Y#
    {codepoint = 120327, with = "z"},   -- MA# ( 𝘇 → z ) MATHEMATICAL SANS-SERIF BOLD SMALL Z → LATIN SMALL LETTER Z#
    {codepoint = 120328, with = "A"},   -- MA# ( 𝘈 → A ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL A → LATIN CAPITAL LETTER A#
    {codepoint = 120329, with = "B"},   -- MA# ( 𝘉 → B ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL B → LATIN CAPITAL LETTER B#
    {codepoint = 120330, with = "C"},   -- MA# ( 𝘊 → C ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL C → LATIN CAPITAL LETTER C#
    {codepoint = 120331, with = "D"},   -- MA# ( 𝘋 → D ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL D → LATIN CAPITAL LETTER D#
    {codepoint = 120332, with = "E"},   -- MA# ( 𝘌 → E ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL E → LATIN CAPITAL LETTER E#
    {codepoint = 120333, with = "F"},   -- MA# ( 𝘍 → F ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL F → LATIN CAPITAL LETTER F#
    {codepoint = 120334, with = "G"},   -- MA# ( 𝘎 → G ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL G → LATIN CAPITAL LETTER G#
    {codepoint = 120335, with = "H"},   -- MA# ( 𝘏 → H ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL H → LATIN CAPITAL LETTER H#
    {codepoint = 120336, with = "l"},   -- MA# ( 𝘐 → l ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL I → LATIN SMALL LETTER L# →I→
    {codepoint = 120337, with = "J"},   -- MA# ( 𝘑 → J ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL J → LATIN CAPITAL LETTER J#
    {codepoint = 120338, with = "K"},   -- MA# ( 𝘒 → K ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL K → LATIN CAPITAL LETTER K#
    {codepoint = 120339, with = "L"},   -- MA# ( 𝘓 → L ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL L → LATIN CAPITAL LETTER L#
    {codepoint = 120340, with = "M"},   -- MA# ( 𝘔 → M ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL M → LATIN CAPITAL LETTER M#
    {codepoint = 120341, with = "N"},   -- MA# ( 𝘕 → N ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL N → LATIN CAPITAL LETTER N#
    {codepoint = 120342, with = "O"},   -- MA# ( 𝘖 → O ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL O → LATIN CAPITAL LETTER O#
    {codepoint = 120343, with = "P"},   -- MA# ( 𝘗 → P ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL P → LATIN CAPITAL LETTER P#
    {codepoint = 120344, with = "Q"},   -- MA# ( 𝘘 → Q ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL Q → LATIN CAPITAL LETTER Q#
    {codepoint = 120345, with = "R"},   -- MA# ( 𝘙 → R ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL R → LATIN CAPITAL LETTER R#
    {codepoint = 120346, with = "S"},   -- MA# ( 𝘚 → S ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL S → LATIN CAPITAL LETTER S#
    {codepoint = 120347, with = "T"},   -- MA# ( 𝘛 → T ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL T → LATIN CAPITAL LETTER T#
    {codepoint = 120348, with = "U"},   -- MA# ( 𝘜 → U ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL U → LATIN CAPITAL LETTER U#
    {codepoint = 120349, with = "V"},   -- MA# ( 𝘝 → V ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL V → LATIN CAPITAL LETTER V#
    {codepoint = 120350, with = "W"},   -- MA# ( 𝘞 → W ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL W → LATIN CAPITAL LETTER W#
    {codepoint = 120351, with = "X"},   -- MA# ( 𝘟 → X ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL X → LATIN CAPITAL LETTER X#
    {codepoint = 120352, with = "Y"},   -- MA# ( 𝘠 → Y ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL Y → LATIN CAPITAL LETTER Y#
    {codepoint = 120353, with = "Z"},   -- MA# ( 𝘡 → Z ) MATHEMATICAL SANS-SERIF ITALIC CAPITAL Z → LATIN CAPITAL LETTER Z#
    {codepoint = 120354, with = "a"},   -- MA# ( 𝘢 → a ) MATHEMATICAL SANS-SERIF ITALIC SMALL A → LATIN SMALL LETTER A#
    {codepoint = 120355, with = "b"},   -- MA# ( 𝘣 → b ) MATHEMATICAL SANS-SERIF ITALIC SMALL B → LATIN SMALL LETTER B#
    {codepoint = 120356, with = "c"},   -- MA# ( 𝘤 → c ) MATHEMATICAL SANS-SERIF ITALIC SMALL C → LATIN SMALL LETTER C#
    {codepoint = 120357, with = "d"},   -- MA# ( 𝘥 → d ) MATHEMATICAL SANS-SERIF ITALIC SMALL D → LATIN SMALL LETTER D#
    {codepoint = 120358, with = "e"},   -- MA# ( 𝘦 → e ) MATHEMATICAL SANS-SERIF ITALIC SMALL E → LATIN SMALL LETTER E#
    {codepoint = 120359, with = "f"},   -- MA# ( 𝘧 → f ) MATHEMATICAL SANS-SERIF ITALIC SMALL F → LATIN SMALL LETTER F#
    {codepoint = 120360, with = "g"},   -- MA# ( 𝘨 → g ) MATHEMATICAL SANS-SERIF ITALIC SMALL G → LATIN SMALL LETTER G#
    {codepoint = 120361, with = "h"},   -- MA# ( 𝘩 → h ) MATHEMATICAL SANS-SERIF ITALIC SMALL H → LATIN SMALL LETTER H#
    {codepoint = 120362, with = "i"},   -- MA# ( 𝘪 → i ) MATHEMATICAL SANS-SERIF ITALIC SMALL I → LATIN SMALL LETTER I#
    {codepoint = 120363, with = "j"},   -- MA# ( 𝘫 → j ) MATHEMATICAL SANS-SERIF ITALIC SMALL J → LATIN SMALL LETTER J#
    {codepoint = 120364, with = "k"},   -- MA# ( 𝘬 → k ) MATHEMATICAL SANS-SERIF ITALIC SMALL K → LATIN SMALL LETTER K#
    {codepoint = 120365, with = "l"},   -- MA# ( 𝘭 → l ) MATHEMATICAL SANS-SERIF ITALIC SMALL L → LATIN SMALL LETTER L#
    {codepoint = 120366, with = "rn"},  -- MA# ( 𝘮 → rn ) MATHEMATICAL SANS-SERIF ITALIC SMALL M → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 120367, with = "n"},   -- MA# ( 𝘯 → n ) MATHEMATICAL SANS-SERIF ITALIC SMALL N → LATIN SMALL LETTER N#
    {codepoint = 120368, with = "o"},   -- MA# ( 𝘰 → o ) MATHEMATICAL SANS-SERIF ITALIC SMALL O → LATIN SMALL LETTER O#
    {codepoint = 120369, with = "p"},   -- MA# ( 𝘱 → p ) MATHEMATICAL SANS-SERIF ITALIC SMALL P → LATIN SMALL LETTER P#
    {codepoint = 120370, with = "q"},   -- MA# ( 𝘲 → q ) MATHEMATICAL SANS-SERIF ITALIC SMALL Q → LATIN SMALL LETTER Q#
    {codepoint = 120371, with = "r"},   -- MA# ( 𝘳 → r ) MATHEMATICAL SANS-SERIF ITALIC SMALL R → LATIN SMALL LETTER R#
    {codepoint = 120372, with = "s"},   -- MA# ( 𝘴 → s ) MATHEMATICAL SANS-SERIF ITALIC SMALL S → LATIN SMALL LETTER S#
    {codepoint = 120373, with = "t"},   -- MA# ( 𝘵 → t ) MATHEMATICAL SANS-SERIF ITALIC SMALL T → LATIN SMALL LETTER T#
    {codepoint = 120374, with = "u"},   -- MA# ( 𝘶 → u ) MATHEMATICAL SANS-SERIF ITALIC SMALL U → LATIN SMALL LETTER U#
    {codepoint = 120375, with = "v"},   -- MA# ( 𝘷 → v ) MATHEMATICAL SANS-SERIF ITALIC SMALL V → LATIN SMALL LETTER V#
    {codepoint = 120376, with = "w"},   -- MA# ( 𝘸 → w ) MATHEMATICAL SANS-SERIF ITALIC SMALL W → LATIN SMALL LETTER W#
    {codepoint = 120377, with = "x"},   -- MA# ( 𝘹 → x ) MATHEMATICAL SANS-SERIF ITALIC SMALL X → LATIN SMALL LETTER X#
    {codepoint = 120378, with = "y"},   -- MA# ( 𝘺 → y ) MATHEMATICAL SANS-SERIF ITALIC SMALL Y → LATIN SMALL LETTER Y#
    {codepoint = 120379, with = "z"},   -- MA# ( 𝘻 → z ) MATHEMATICAL SANS-SERIF ITALIC SMALL Z → LATIN SMALL LETTER Z#
    {codepoint = 120380, with = "A"},   -- MA# ( 𝘼 → A ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL A → LATIN CAPITAL LETTER A#
    {codepoint = 120381, with = "B"},   -- MA# ( 𝘽 → B ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL B → LATIN CAPITAL LETTER B#
    {codepoint = 120382, with = "C"},   -- MA# ( 𝘾 → C ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL C → LATIN CAPITAL LETTER C#
    {codepoint = 120383, with = "D"},   -- MA# ( 𝘿 → D ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL D → LATIN CAPITAL LETTER D#
    {codepoint = 120384, with = "E"},   -- MA# ( 𝙀 → E ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL E → LATIN CAPITAL LETTER E#
    {codepoint = 120385, with = "F"},   -- MA# ( 𝙁 → F ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL F → LATIN CAPITAL LETTER F#
    {codepoint = 120386, with = "G"},   -- MA# ( 𝙂 → G ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL G → LATIN CAPITAL LETTER G#
    {codepoint = 120387, with = "H"},   -- MA# ( 𝙃 → H ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL H → LATIN CAPITAL LETTER H#
    {codepoint = 120388, with = "l"},   -- MA# ( 𝙄 → l ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL I → LATIN SMALL LETTER L# →I→
    {codepoint = 120389, with = "J"},   -- MA# ( 𝙅 → J ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL J → LATIN CAPITAL LETTER J#
    {codepoint = 120390, with = "K"},   -- MA# ( 𝙆 → K ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL K → LATIN CAPITAL LETTER K#
    {codepoint = 120391, with = "L"},   -- MA# ( 𝙇 → L ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL L → LATIN CAPITAL LETTER L#
    {codepoint = 120392, with = "M"},   -- MA# ( 𝙈 → M ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL M → LATIN CAPITAL LETTER M#
    {codepoint = 120393, with = "N"},   -- MA# ( 𝙉 → N ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL N → LATIN CAPITAL LETTER N#
    {codepoint = 120394, with = "O"},   -- MA# ( 𝙊 → O ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL O → LATIN CAPITAL LETTER O#
    {codepoint = 120395, with = "P"},   -- MA# ( 𝙋 → P ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL P → LATIN CAPITAL LETTER P#
    {codepoint = 120396, with = "Q"},   -- MA# ( 𝙌 → Q ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL Q → LATIN CAPITAL LETTER Q#
    {codepoint = 120397, with = "R"},   -- MA# ( 𝙍 → R ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL R → LATIN CAPITAL LETTER R#
    {codepoint = 120398, with = "S"},   -- MA# ( 𝙎 → S ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL S → LATIN CAPITAL LETTER S#
    {codepoint = 120399, with = "T"},   -- MA# ( 𝙏 → T ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL T → LATIN CAPITAL LETTER T#
    {codepoint = 120400, with = "U"},   -- MA# ( 𝙐 → U ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL U → LATIN CAPITAL LETTER U#
    {codepoint = 120401, with = "V"},   -- MA# ( 𝙑 → V ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL V → LATIN CAPITAL LETTER V#
    {codepoint = 120402, with = "W"},   -- MA# ( 𝙒 → W ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL W → LATIN CAPITAL LETTER W#
    {codepoint = 120403, with = "X"},   -- MA# ( 𝙓 → X ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL X → LATIN CAPITAL LETTER X#
    {codepoint = 120404, with = "Y"},   -- MA# ( 𝙔 → Y ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL Y → LATIN CAPITAL LETTER Y#
    {codepoint = 120405, with = "Z"},   -- MA# ( 𝙕 → Z ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL Z → LATIN CAPITAL LETTER Z#
    {codepoint = 120406, with = "a"},   -- MA# ( 𝙖 → a ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL A → LATIN SMALL LETTER A#
    {codepoint = 120407, with = "b"},   -- MA# ( 𝙗 → b ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL B → LATIN SMALL LETTER B#
    {codepoint = 120408, with = "c"},   -- MA# ( 𝙘 → c ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL C → LATIN SMALL LETTER C#
    {codepoint = 120409, with = "d"},   -- MA# ( 𝙙 → d ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL D → LATIN SMALL LETTER D#
    {codepoint = 120410, with = "e"},   -- MA# ( 𝙚 → e ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL E → LATIN SMALL LETTER E#
    {codepoint = 120411, with = "f"},   -- MA# ( 𝙛 → f ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL F → LATIN SMALL LETTER F#
    {codepoint = 120412, with = "g"},   -- MA# ( 𝙜 → g ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL G → LATIN SMALL LETTER G#
    {codepoint = 120413, with = "h"},   -- MA# ( 𝙝 → h ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL H → LATIN SMALL LETTER H#
    {codepoint = 120414, with = "i"},   -- MA# ( 𝙞 → i ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL I → LATIN SMALL LETTER I#
    {codepoint = 120415, with = "j"},   -- MA# ( 𝙟 → j ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL J → LATIN SMALL LETTER J#
    {codepoint = 120416, with = "k"},   -- MA# ( 𝙠 → k ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL K → LATIN SMALL LETTER K#
    {codepoint = 120417, with = "l"},   -- MA# ( 𝙡 → l ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL L → LATIN SMALL LETTER L#
    {codepoint = 120418, with = "rn"},  -- MA# ( 𝙢 → rn ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL M → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 120419, with = "n"},   -- MA# ( 𝙣 → n ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL N → LATIN SMALL LETTER N#
    {codepoint = 120420, with = "o"},   -- MA# ( 𝙤 → o ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL O → LATIN SMALL LETTER O#
    {codepoint = 120421, with = "p"},   -- MA# ( 𝙥 → p ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL P → LATIN SMALL LETTER P#
    {codepoint = 120422, with = "q"},   -- MA# ( 𝙦 → q ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL Q → LATIN SMALL LETTER Q#
    {codepoint = 120423, with = "r"},   -- MA# ( 𝙧 → r ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL R → LATIN SMALL LETTER R#
    {codepoint = 120424, with = "s"},   -- MA# ( 𝙨 → s ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL S → LATIN SMALL LETTER S#
    {codepoint = 120425, with = "t"},   -- MA# ( 𝙩 → t ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL T → LATIN SMALL LETTER T#
    {codepoint = 120426, with = "u"},   -- MA# ( 𝙪 → u ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL U → LATIN SMALL LETTER U#
    {codepoint = 120427, with = "v"},   -- MA# ( 𝙫 → v ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL V → LATIN SMALL LETTER V#
    {codepoint = 120428, with = "w"},   -- MA# ( 𝙬 → w ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL W → LATIN SMALL LETTER W#
    {codepoint = 120429, with = "x"},   -- MA# ( 𝙭 → x ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL X → LATIN SMALL LETTER X#
    {codepoint = 120430, with = "y"},   -- MA# ( 𝙮 → y ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL Y → LATIN SMALL LETTER Y#
    {codepoint = 120431, with = "z"},   -- MA# ( 𝙯 → z ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL Z → LATIN SMALL LETTER Z#
    {codepoint = 120432, with = "A"},   -- MA# ( 𝙰 → A ) MATHEMATICAL MONOSPACE CAPITAL A → LATIN CAPITAL LETTER A#
    {codepoint = 120433, with = "B"},   -- MA# ( 𝙱 → B ) MATHEMATICAL MONOSPACE CAPITAL B → LATIN CAPITAL LETTER B#
    {codepoint = 120434, with = "C"},   -- MA# ( 𝙲 → C ) MATHEMATICAL MONOSPACE CAPITAL C → LATIN CAPITAL LETTER C#
    {codepoint = 120435, with = "D"},   -- MA# ( 𝙳 → D ) MATHEMATICAL MONOSPACE CAPITAL D → LATIN CAPITAL LETTER D#
    {codepoint = 120436, with = "E"},   -- MA# ( 𝙴 → E ) MATHEMATICAL MONOSPACE CAPITAL E → LATIN CAPITAL LETTER E#
    {codepoint = 120437, with = "F"},   -- MA# ( 𝙵 → F ) MATHEMATICAL MONOSPACE CAPITAL F → LATIN CAPITAL LETTER F#
    {codepoint = 120438, with = "G"},   -- MA# ( 𝙶 → G ) MATHEMATICAL MONOSPACE CAPITAL G → LATIN CAPITAL LETTER G#
    {codepoint = 120439, with = "H"},   -- MA# ( 𝙷 → H ) MATHEMATICAL MONOSPACE CAPITAL H → LATIN CAPITAL LETTER H#
    {codepoint = 120440, with = "l"},   -- MA# ( 𝙸 → l ) MATHEMATICAL MONOSPACE CAPITAL I → LATIN SMALL LETTER L# →I→
    {codepoint = 120441, with = "J"},   -- MA# ( 𝙹 → J ) MATHEMATICAL MONOSPACE CAPITAL J → LATIN CAPITAL LETTER J#
    {codepoint = 120442, with = "K"},   -- MA# ( 𝙺 → K ) MATHEMATICAL MONOSPACE CAPITAL K → LATIN CAPITAL LETTER K#
    {codepoint = 120443, with = "L"},   -- MA# ( 𝙻 → L ) MATHEMATICAL MONOSPACE CAPITAL L → LATIN CAPITAL LETTER L#
    {codepoint = 120444, with = "M"},   -- MA# ( 𝙼 → M ) MATHEMATICAL MONOSPACE CAPITAL M → LATIN CAPITAL LETTER M#
    {codepoint = 120445, with = "N"},   -- MA# ( 𝙽 → N ) MATHEMATICAL MONOSPACE CAPITAL N → LATIN CAPITAL LETTER N#
    {codepoint = 120446, with = "O"},   -- MA# ( 𝙾 → O ) MATHEMATICAL MONOSPACE CAPITAL O → LATIN CAPITAL LETTER O#
    {codepoint = 120447, with = "P"},   -- MA# ( 𝙿 → P ) MATHEMATICAL MONOSPACE CAPITAL P → LATIN CAPITAL LETTER P#
    {codepoint = 120448, with = "Q"},   -- MA# ( 𝚀 → Q ) MATHEMATICAL MONOSPACE CAPITAL Q → LATIN CAPITAL LETTER Q#
    {codepoint = 120449, with = "R"},   -- MA# ( 𝚁 → R ) MATHEMATICAL MONOSPACE CAPITAL R → LATIN CAPITAL LETTER R#
    {codepoint = 120450, with = "S"},   -- MA# ( 𝚂 → S ) MATHEMATICAL MONOSPACE CAPITAL S → LATIN CAPITAL LETTER S#
    {codepoint = 120451, with = "T"},   -- MA# ( 𝚃 → T ) MATHEMATICAL MONOSPACE CAPITAL T → LATIN CAPITAL LETTER T#
    {codepoint = 120452, with = "U"},   -- MA# ( 𝚄 → U ) MATHEMATICAL MONOSPACE CAPITAL U → LATIN CAPITAL LETTER U#
    {codepoint = 120453, with = "V"},   -- MA# ( 𝚅 → V ) MATHEMATICAL MONOSPACE CAPITAL V → LATIN CAPITAL LETTER V#
    {codepoint = 120454, with = "W"},   -- MA# ( 𝚆 → W ) MATHEMATICAL MONOSPACE CAPITAL W → LATIN CAPITAL LETTER W#
    {codepoint = 120455, with = "X"},   -- MA# ( 𝚇 → X ) MATHEMATICAL MONOSPACE CAPITAL X → LATIN CAPITAL LETTER X#
    {codepoint = 120456, with = "Y"},   -- MA# ( 𝚈 → Y ) MATHEMATICAL MONOSPACE CAPITAL Y → LATIN CAPITAL LETTER Y#
    {codepoint = 120457, with = "Z"},   -- MA# ( 𝚉 → Z ) MATHEMATICAL MONOSPACE CAPITAL Z → LATIN CAPITAL LETTER Z#
    {codepoint = 120458, with = "a"},   -- MA# ( 𝚊 → a ) MATHEMATICAL MONOSPACE SMALL A → LATIN SMALL LETTER A#
    {codepoint = 120459, with = "b"},   -- MA# ( 𝚋 → b ) MATHEMATICAL MONOSPACE SMALL B → LATIN SMALL LETTER B#
    {codepoint = 120460, with = "c"},   -- MA# ( 𝚌 → c ) MATHEMATICAL MONOSPACE SMALL C → LATIN SMALL LETTER C#
    {codepoint = 120461, with = "d"},   -- MA# ( 𝚍 → d ) MATHEMATICAL MONOSPACE SMALL D → LATIN SMALL LETTER D#
    {codepoint = 120462, with = "e"},   -- MA# ( 𝚎 → e ) MATHEMATICAL MONOSPACE SMALL E → LATIN SMALL LETTER E#
    {codepoint = 120463, with = "f"},   -- MA# ( 𝚏 → f ) MATHEMATICAL MONOSPACE SMALL F → LATIN SMALL LETTER F#
    {codepoint = 120464, with = "g"},   -- MA# ( 𝚐 → g ) MATHEMATICAL MONOSPACE SMALL G → LATIN SMALL LETTER G#
    {codepoint = 120465, with = "h"},   -- MA# ( 𝚑 → h ) MATHEMATICAL MONOSPACE SMALL H → LATIN SMALL LETTER H#
    {codepoint = 120466, with = "i"},   -- MA# ( 𝚒 → i ) MATHEMATICAL MONOSPACE SMALL I → LATIN SMALL LETTER I#
    {codepoint = 120467, with = "j"},   -- MA# ( 𝚓 → j ) MATHEMATICAL MONOSPACE SMALL J → LATIN SMALL LETTER J#
    {codepoint = 120468, with = "k"},   -- MA# ( 𝚔 → k ) MATHEMATICAL MONOSPACE SMALL K → LATIN SMALL LETTER K#
    {codepoint = 120469, with = "l"},   -- MA# ( 𝚕 → l ) MATHEMATICAL MONOSPACE SMALL L → LATIN SMALL LETTER L#
    {codepoint = 120470, with = "rn"},  -- MA# ( 𝚖 → rn ) MATHEMATICAL MONOSPACE SMALL M → LATIN SMALL LETTER R, LATIN SMALL LETTER N# →m→
    {codepoint = 120471, with = "n"},   -- MA# ( 𝚗 → n ) MATHEMATICAL MONOSPACE SMALL N → LATIN SMALL LETTER N#
    {codepoint = 120472, with = "o"},   -- MA# ( 𝚘 → o ) MATHEMATICAL MONOSPACE SMALL O → LATIN SMALL LETTER O#
    {codepoint = 120473, with = "p"},   -- MA# ( 𝚙 → p ) MATHEMATICAL MONOSPACE SMALL P → LATIN SMALL LETTER P#
    {codepoint = 120474, with = "q"},   -- MA# ( 𝚚 → q ) MATHEMATICAL MONOSPACE SMALL Q → LATIN SMALL LETTER Q#
    {codepoint = 120475, with = "r"},   -- MA# ( 𝚛 → r ) MATHEMATICAL MONOSPACE SMALL R → LATIN SMALL LETTER R#
    {codepoint = 120476, with = "s"},   -- MA# ( 𝚜 → s ) MATHEMATICAL MONOSPACE SMALL S → LATIN SMALL LETTER S#
    {codepoint = 120477, with = "t"},   -- MA# ( 𝚝 → t ) MATHEMATICAL MONOSPACE SMALL T → LATIN SMALL LETTER T#
    {codepoint = 120478, with = "u"},   -- MA# ( 𝚞 → u ) MATHEMATICAL MONOSPACE SMALL U → LATIN SMALL LETTER U#
    {codepoint = 120479, with = "v"},   -- MA# ( 𝚟 → v ) MATHEMATICAL MONOSPACE SMALL V → LATIN SMALL LETTER V#
    {codepoint = 120480, with = "w"},   -- MA# ( 𝚠 → w ) MATHEMATICAL MONOSPACE SMALL W → LATIN SMALL LETTER W#
    {codepoint = 120481, with = "x"},   -- MA# ( 𝚡 → x ) MATHEMATICAL MONOSPACE SMALL X → LATIN SMALL LETTER X#
    {codepoint = 120482, with = "y"},   -- MA# ( 𝚢 → y ) MATHEMATICAL MONOSPACE SMALL Y → LATIN SMALL LETTER Y#
    {codepoint = 120483, with = "z"},   -- MA# ( 𝚣 → z ) MATHEMATICAL MONOSPACE SMALL Z → LATIN SMALL LETTER Z#
    {codepoint = 120484, with = "i"},   -- MA# ( 𝚤 → i ) MATHEMATICAL ITALIC SMALL DOTLESS I → LATIN SMALL LETTER I# →ı→
    {codepoint = 120488, with = "A"},   -- MA# ( 𝚨 → A ) MATHEMATICAL BOLD CAPITAL ALPHA → LATIN CAPITAL LETTER A# →𝐀→
    {codepoint = 120489, with = "B"},   -- MA# ( 𝚩 → B ) MATHEMATICAL BOLD CAPITAL BETA → LATIN CAPITAL LETTER B# →Β→
    {codepoint = 120492, with = "E"},   -- MA# ( 𝚬 → E ) MATHEMATICAL BOLD CAPITAL EPSILON → LATIN CAPITAL LETTER E# →𝐄→
    {codepoint = 120493, with = "Z"},   -- MA# ( 𝚭 → Z ) MATHEMATICAL BOLD CAPITAL ZETA → LATIN CAPITAL LETTER Z# →Ζ→
    {codepoint = 120494, with = "H"},   -- MA# ( 𝚮 → H ) MATHEMATICAL BOLD CAPITAL ETA → LATIN CAPITAL LETTER H# →Η→
    {codepoint = 120496, with = "l"},   -- MA# ( 𝚰 → l ) MATHEMATICAL BOLD CAPITAL IOTA → LATIN SMALL LETTER L# →Ι→
    {codepoint = 120497, with = "K"},   -- MA# ( 𝚱 → K ) MATHEMATICAL BOLD CAPITAL KAPPA → LATIN CAPITAL LETTER K# →Κ→
    {codepoint = 120499, with = "M"},   -- MA# ( 𝚳 → M ) MATHEMATICAL BOLD CAPITAL MU → LATIN CAPITAL LETTER M# →𝐌→
    {codepoint = 120500, with = "N"},   -- MA# ( 𝚴 → N ) MATHEMATICAL BOLD CAPITAL NU → LATIN CAPITAL LETTER N# →𝐍→
    {codepoint = 120502, with = "O"},   -- MA# ( 𝚶 → O ) MATHEMATICAL BOLD CAPITAL OMICRON → LATIN CAPITAL LETTER O# →𝐎→
    {codepoint = 120504, with = "P"},   -- MA# ( 𝚸 → P ) MATHEMATICAL BOLD CAPITAL RHO → LATIN CAPITAL LETTER P# →𝐏→
    {codepoint = 120507, with = "T"},   -- MA# ( 𝚻 → T ) MATHEMATICAL BOLD CAPITAL TAU → LATIN CAPITAL LETTER T# →Τ→
    {codepoint = 120508, with = "Y"},   -- MA# ( 𝚼 → Y ) MATHEMATICAL BOLD CAPITAL UPSILON → LATIN CAPITAL LETTER Y# →Υ→
    {codepoint = 120510, with = "X"},   -- MA# ( 𝚾 → X ) MATHEMATICAL BOLD CAPITAL CHI → LATIN CAPITAL LETTER X# →Χ→
    {codepoint = 120514, with = "a"},   -- MA# ( 𝛂 → a ) MATHEMATICAL BOLD SMALL ALPHA → LATIN SMALL LETTER A# →α→
    {codepoint = 120516, with = "y"},   -- MA# ( 𝛄 → y ) MATHEMATICAL BOLD SMALL GAMMA → LATIN SMALL LETTER Y# →γ→
    {codepoint = 120522, with = "i"},   -- MA# ( 𝛊 → i ) MATHEMATICAL BOLD SMALL IOTA → LATIN SMALL LETTER I# →ι→
    {codepoint = 120526, with = "v"},   -- MA# ( 𝛎 → v ) MATHEMATICAL BOLD SMALL NU → LATIN SMALL LETTER V# →ν→
    {codepoint = 120528, with = "o"},   -- MA# ( 𝛐 → o ) MATHEMATICAL BOLD SMALL OMICRON → LATIN SMALL LETTER O# →𝐨→
    {codepoint = 120530, with = "p"},   -- MA# ( 𝛒 → p ) MATHEMATICAL BOLD SMALL RHO → LATIN SMALL LETTER P# →ρ→
    {codepoint = 120532, with = "o"},   -- MA# ( 𝛔 → o ) MATHEMATICAL BOLD SMALL SIGMA → LATIN SMALL LETTER O# →σ→
    {codepoint = 120534, with = "u"},   -- MA# ( 𝛖 → u ) MATHEMATICAL BOLD SMALL UPSILON → LATIN SMALL LETTER U# →υ→→ʋ→
    {codepoint = 120544, with = "p"},   -- MA# ( 𝛠 → p ) MATHEMATICAL BOLD RHO SYMBOL → LATIN SMALL LETTER P# →ρ→
    {codepoint = 120546, with = "A"},   -- MA# ( 𝛢 → A ) MATHEMATICAL ITALIC CAPITAL ALPHA → LATIN CAPITAL LETTER A# →Α→
    {codepoint = 120547, with = "B"},   -- MA# ( 𝛣 → B ) MATHEMATICAL ITALIC CAPITAL BETA → LATIN CAPITAL LETTER B# →Β→
    {codepoint = 120550, with = "E"},   -- MA# ( 𝛦 → E ) MATHEMATICAL ITALIC CAPITAL EPSILON → LATIN CAPITAL LETTER E# →Ε→
    {codepoint = 120551, with = "Z"},   -- MA# ( 𝛧 → Z ) MATHEMATICAL ITALIC CAPITAL ZETA → LATIN CAPITAL LETTER Z# →𝑍→
    {codepoint = 120552, with = "H"},   -- MA# ( 𝛨 → H ) MATHEMATICAL ITALIC CAPITAL ETA → LATIN CAPITAL LETTER H# →Η→
    {codepoint = 120554, with = "l"},   -- MA# ( 𝛪 → l ) MATHEMATICAL ITALIC CAPITAL IOTA → LATIN SMALL LETTER L# →Ι→
    {codepoint = 120555, with = "K"},   -- MA# ( 𝛫 → K ) MATHEMATICAL ITALIC CAPITAL KAPPA → LATIN CAPITAL LETTER K# →𝐾→
    {codepoint = 120557, with = "M"},   -- MA# ( 𝛭 → M ) MATHEMATICAL ITALIC CAPITAL MU → LATIN CAPITAL LETTER M# →𝑀→
    {codepoint = 120558, with = "N"},   -- MA# ( 𝛮 → N ) MATHEMATICAL ITALIC CAPITAL NU → LATIN CAPITAL LETTER N# →𝑁→
    {codepoint = 120560, with = "O"},   -- MA# ( 𝛰 → O ) MATHEMATICAL ITALIC CAPITAL OMICRON → LATIN CAPITAL LETTER O# →𝑂→
    {codepoint = 120562, with = "P"},   -- MA# ( 𝛲 → P ) MATHEMATICAL ITALIC CAPITAL RHO → LATIN CAPITAL LETTER P# →Ρ→
    {codepoint = 120565, with = "T"},   -- MA# ( 𝛵 → T ) MATHEMATICAL ITALIC CAPITAL TAU → LATIN CAPITAL LETTER T# →Τ→
    {codepoint = 120566, with = "Y"},   -- MA# ( 𝛶 → Y ) MATHEMATICAL ITALIC CAPITAL UPSILON → LATIN CAPITAL LETTER Y# →Υ→
    {codepoint = 120568, with = "X"},   -- MA# ( 𝛸 → X ) MATHEMATICAL ITALIC CAPITAL CHI → LATIN CAPITAL LETTER X# →Χ→
    {codepoint = 120572, with = "a"},   -- MA# ( 𝛼 → a ) MATHEMATICAL ITALIC SMALL ALPHA → LATIN SMALL LETTER A# →α→
    {codepoint = 120574, with = "y"},   -- MA# ( 𝛾 → y ) MATHEMATICAL ITALIC SMALL GAMMA → LATIN SMALL LETTER Y# →γ→
    {codepoint = 120580, with = "i"},   -- MA# ( 𝜄 → i ) MATHEMATICAL ITALIC SMALL IOTA → LATIN SMALL LETTER I# →ι→
    {codepoint = 120584, with = "v"},   -- MA# ( 𝜈 → v ) MATHEMATICAL ITALIC SMALL NU → LATIN SMALL LETTER V# →ν→
    {codepoint = 120586, with = "o"},   -- MA# ( 𝜊 → o ) MATHEMATICAL ITALIC SMALL OMICRON → LATIN SMALL LETTER O# →𝑜→
    {codepoint = 120588, with = "p"},   -- MA# ( 𝜌 → p ) MATHEMATICAL ITALIC SMALL RHO → LATIN SMALL LETTER P# →ρ→
    {codepoint = 120590, with = "o"},   -- MA# ( 𝜎 → o ) MATHEMATICAL ITALIC SMALL SIGMA → LATIN SMALL LETTER O# →σ→
    {codepoint = 120592, with = "u"},   -- MA# ( 𝜐 → u ) MATHEMATICAL ITALIC SMALL UPSILON → LATIN SMALL LETTER U# →υ→→ʋ→
    {codepoint = 120602, with = "p"},   -- MA# ( 𝜚 → p ) MATHEMATICAL ITALIC RHO SYMBOL → LATIN SMALL LETTER P# →ρ→
    {codepoint = 120604, with = "A"},   -- MA# ( 𝜜 → A ) MATHEMATICAL BOLD ITALIC CAPITAL ALPHA → LATIN CAPITAL LETTER A# →Α→
    {codepoint = 120605, with = "B"},   -- MA# ( 𝜝 → B ) MATHEMATICAL BOLD ITALIC CAPITAL BETA → LATIN CAPITAL LETTER B# →Β→
    {codepoint = 120608, with = "E"},   -- MA# ( 𝜠 → E ) MATHEMATICAL BOLD ITALIC CAPITAL EPSILON → LATIN CAPITAL LETTER E# →Ε→
    {codepoint = 120609, with = "Z"},   -- MA# ( 𝜡 → Z ) MATHEMATICAL BOLD ITALIC CAPITAL ZETA → LATIN CAPITAL LETTER Z# →Ζ→
    {codepoint = 120610, with = "H"},   -- MA# ( 𝜢 → H ) MATHEMATICAL BOLD ITALIC CAPITAL ETA → LATIN CAPITAL LETTER H# →𝑯→
    {codepoint = 120612, with = "l"},   -- MA# ( 𝜤 → l ) MATHEMATICAL BOLD ITALIC CAPITAL IOTA → LATIN SMALL LETTER L# →Ι→
    {codepoint = 120613, with = "K"},   -- MA# ( 𝜥 → K ) MATHEMATICAL BOLD ITALIC CAPITAL KAPPA → LATIN CAPITAL LETTER K# →𝑲→
    {codepoint = 120615, with = "M"},   -- MA# ( 𝜧 → M ) MATHEMATICAL BOLD ITALIC CAPITAL MU → LATIN CAPITAL LETTER M# →𝑴→
    {codepoint = 120616, with = "N"},   -- MA# ( 𝜨 → N ) MATHEMATICAL BOLD ITALIC CAPITAL NU → LATIN CAPITAL LETTER N# →𝑵→
    {codepoint = 120618, with = "O"},   -- MA# ( 𝜪 → O ) MATHEMATICAL BOLD ITALIC CAPITAL OMICRON → LATIN CAPITAL LETTER O# →𝑶→
    {codepoint = 120620, with = "P"},   -- MA# ( 𝜬 → P ) MATHEMATICAL BOLD ITALIC CAPITAL RHO → LATIN CAPITAL LETTER P# →Ρ→
    {codepoint = 120623, with = "T"},   -- MA# ( 𝜯 → T ) MATHEMATICAL BOLD ITALIC CAPITAL TAU → LATIN CAPITAL LETTER T# →Τ→
    {codepoint = 120624, with = "Y"},   -- MA# ( 𝜰 → Y ) MATHEMATICAL BOLD ITALIC CAPITAL UPSILON → LATIN CAPITAL LETTER Y# →Υ→
    {codepoint = 120626, with = "X"},   -- MA# ( 𝜲 → X ) MATHEMATICAL BOLD ITALIC CAPITAL CHI → LATIN CAPITAL LETTER X# →𝑿→
    {codepoint = 120630, with = "a"},   -- MA# ( 𝜶 → a ) MATHEMATICAL BOLD ITALIC SMALL ALPHA → LATIN SMALL LETTER A# →α→
    {codepoint = 120632, with = "y"},   -- MA# ( 𝜸 → y ) MATHEMATICAL BOLD ITALIC SMALL GAMMA → LATIN SMALL LETTER Y# →γ→
    {codepoint = 120638, with = "i"},   -- MA# ( 𝜾 → i ) MATHEMATICAL BOLD ITALIC SMALL IOTA → LATIN SMALL LETTER I# →ι→
    {codepoint = 120642, with = "v"},   -- MA# ( 𝝂 → v ) MATHEMATICAL BOLD ITALIC SMALL NU → LATIN SMALL LETTER V# →ν→
    {codepoint = 120644, with = "o"},   -- MA# ( 𝝄 → o ) MATHEMATICAL BOLD ITALIC SMALL OMICRON → LATIN SMALL LETTER O# →𝒐→
    {codepoint = 120646, with = "p"},   -- MA# ( 𝝆 → p ) MATHEMATICAL BOLD ITALIC SMALL RHO → LATIN SMALL LETTER P# →ρ→
    {codepoint = 120648, with = "o"},   -- MA# ( 𝝈 → o ) MATHEMATICAL BOLD ITALIC SMALL SIGMA → LATIN SMALL LETTER O# →σ→
    {codepoint = 120650, with = "u"},   -- MA# ( 𝝊 → u ) MATHEMATICAL BOLD ITALIC SMALL UPSILON → LATIN SMALL LETTER U# →υ→→ʋ→
    {codepoint = 120660, with = "p"},   -- MA# ( 𝝔 → p ) MATHEMATICAL BOLD ITALIC RHO SYMBOL → LATIN SMALL LETTER P# →ρ→
    {codepoint = 120662, with = "A"},   -- MA# ( 𝝖 → A ) MATHEMATICAL SANS-SERIF BOLD CAPITAL ALPHA → LATIN CAPITAL LETTER A# →Α→
    {codepoint = 120663, with = "B"},   -- MA# ( 𝝗 → B ) MATHEMATICAL SANS-SERIF BOLD CAPITAL BETA → LATIN CAPITAL LETTER B# →Β→
    {codepoint = 120666, with = "E"},   -- MA# ( 𝝚 → E ) MATHEMATICAL SANS-SERIF BOLD CAPITAL EPSILON → LATIN CAPITAL LETTER E# →Ε→
    {codepoint = 120667, with = "Z"},   -- MA# ( 𝝛 → Z ) MATHEMATICAL SANS-SERIF BOLD CAPITAL ZETA → LATIN CAPITAL LETTER Z# →Ζ→
    {codepoint = 120668, with = "H"},   -- MA# ( 𝝜 → H ) MATHEMATICAL SANS-SERIF BOLD CAPITAL ETA → LATIN CAPITAL LETTER H# →Η→
    {codepoint = 120670, with = "l"},   -- MA# ( 𝝞 → l ) MATHEMATICAL SANS-SERIF BOLD CAPITAL IOTA → LATIN SMALL LETTER L# →Ι→
    {codepoint = 120671, with = "K"},   -- MA# ( 𝝟 → K ) MATHEMATICAL SANS-SERIF BOLD CAPITAL KAPPA → LATIN CAPITAL LETTER K# →Κ→
    {codepoint = 120673, with = "M"},   -- MA# ( 𝝡 → M ) MATHEMATICAL SANS-SERIF BOLD CAPITAL MU → LATIN CAPITAL LETTER M# →Μ→
    {codepoint = 120674, with = "N"},   -- MA# ( 𝝢 → N ) MATHEMATICAL SANS-SERIF BOLD CAPITAL NU → LATIN CAPITAL LETTER N# →Ν→
    {codepoint = 120676, with = "O"},   -- MA# ( 𝝤 → O ) MATHEMATICAL SANS-SERIF BOLD CAPITAL OMICRON → LATIN CAPITAL LETTER O# →Ο→
    {codepoint = 120678, with = "P"},   -- MA# ( 𝝦 → P ) MATHEMATICAL SANS-SERIF BOLD CAPITAL RHO → LATIN CAPITAL LETTER P# →Ρ→
    {codepoint = 120681, with = "T"},   -- MA# ( 𝝩 → T ) MATHEMATICAL SANS-SERIF BOLD CAPITAL TAU → LATIN CAPITAL LETTER T# →Τ→
    {codepoint = 120682, with = "Y"},   -- MA# ( 𝝪 → Y ) MATHEMATICAL SANS-SERIF BOLD CAPITAL UPSILON → LATIN CAPITAL LETTER Y# →Υ→
    {codepoint = 120684, with = "X"},   -- MA# ( 𝝬 → X ) MATHEMATICAL SANS-SERIF BOLD CAPITAL CHI → LATIN CAPITAL LETTER X# →Χ→
    {codepoint = 120688, with = "a"},   -- MA# ( 𝝰 → a ) MATHEMATICAL SANS-SERIF BOLD SMALL ALPHA → LATIN SMALL LETTER A# →α→
    {codepoint = 120690, with = "y"},   -- MA# ( 𝝲 → y ) MATHEMATICAL SANS-SERIF BOLD SMALL GAMMA → LATIN SMALL LETTER Y# →γ→
    {codepoint = 120696, with = "i"},   -- MA# ( 𝝸 → i ) MATHEMATICAL SANS-SERIF BOLD SMALL IOTA → LATIN SMALL LETTER I# →ι→
    {codepoint = 120700, with = "v"},   -- MA# ( 𝝼 → v ) MATHEMATICAL SANS-SERIF BOLD SMALL NU → LATIN SMALL LETTER V# →ν→
    {codepoint = 120702, with = "o"},   -- MA# ( 𝝾 → o ) MATHEMATICAL SANS-SERIF BOLD SMALL OMICRON → LATIN SMALL LETTER O# →ο→
    {codepoint = 120704, with = "p"},   -- MA# ( 𝞀 → p ) MATHEMATICAL SANS-SERIF BOLD SMALL RHO → LATIN SMALL LETTER P# →ρ→
    {codepoint = 120706, with = "o"},   -- MA# ( 𝞂 → o ) MATHEMATICAL SANS-SERIF BOLD SMALL SIGMA → LATIN SMALL LETTER O# →σ→
    {codepoint = 120708, with = "u"},   -- MA# ( 𝞄 → u ) MATHEMATICAL SANS-SERIF BOLD SMALL UPSILON → LATIN SMALL LETTER U# →υ→→ʋ→
    {codepoint = 120718, with = "p"},   -- MA# ( 𝞎 → p ) MATHEMATICAL SANS-SERIF BOLD RHO SYMBOL → LATIN SMALL LETTER P# →ρ→
    {codepoint = 120720, with = "A"},   -- MA# ( 𝞐 → A ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL ALPHA → LATIN CAPITAL LETTER A# →Α→
    {codepoint = 120721, with = "B"},   -- MA# ( 𝞑 → B ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL BETA → LATIN CAPITAL LETTER B# →Β→
    {codepoint = 120724, with = "E"},   -- MA# ( 𝞔 → E ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL EPSILON → LATIN CAPITAL LETTER E# →Ε→
    {codepoint = 120725, with = "Z"},   -- MA# ( 𝞕 → Z ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL ZETA → LATIN CAPITAL LETTER Z# →Ζ→
    {codepoint = 120726, with = "H"},   -- MA# ( 𝞖 → H ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL ETA → LATIN CAPITAL LETTER H# →Η→
    {codepoint = 120728, with = "l"},   -- MA# ( 𝞘 → l ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL IOTA → LATIN SMALL LETTER L# →Ι→
    {codepoint = 120729, with = "K"},   -- MA# ( 𝞙 → K ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL KAPPA → LATIN CAPITAL LETTER K# →Κ→
    {codepoint = 120731, with = "M"},   -- MA# ( 𝞛 → M ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL MU → LATIN CAPITAL LETTER M# →Μ→
    {codepoint = 120732, with = "N"},   -- MA# ( 𝞜 → N ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL NU → LATIN CAPITAL LETTER N# →Ν→
    {codepoint = 120734, with = "O"},   -- MA# ( 𝞞 → O ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL OMICRON → LATIN CAPITAL LETTER O# →Ο→
    {codepoint = 120736, with = "P"},   -- MA# ( 𝞠 → P ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL RHO → LATIN CAPITAL LETTER P# →Ρ→
    {codepoint = 120739, with = "T"},   -- MA# ( 𝞣 → T ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL TAU → LATIN CAPITAL LETTER T# →Τ→
    {codepoint = 120740, with = "Y"},   -- MA# ( 𝞤 → Y ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL UPSILON → LATIN CAPITAL LETTER Y# →Υ→
    {codepoint = 120742, with = "X"},   -- MA# ( 𝞦 → X ) MATHEMATICAL SANS-SERIF BOLD ITALIC CAPITAL CHI → LATIN CAPITAL LETTER X# →Χ→
    {codepoint = 120746, with = "a"},   -- MA# ( 𝞪 → a ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL ALPHA → LATIN SMALL LETTER A# →α→
    {codepoint = 120748, with = "y"},   -- MA# ( 𝞬 → y ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL GAMMA → LATIN SMALL LETTER Y# →γ→
    {codepoint = 120754, with = "i"},   -- MA# ( 𝞲 → i ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL IOTA → LATIN SMALL LETTER I# →ι→
    {codepoint = 120758, with = "v"},   -- MA# ( 𝞶 → v ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL NU → LATIN SMALL LETTER V# →ν→
    {codepoint = 120760, with = "o"},   -- MA# ( 𝞸 → o ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL OMICRON → LATIN SMALL LETTER O# →ο→
    {codepoint = 120762, with = "p"},   -- MA# ( 𝞺 → p ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL RHO → LATIN SMALL LETTER P# →ρ→
    {codepoint = 120764, with = "o"},   -- MA# ( 𝞼 → o ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL SIGMA → LATIN SMALL LETTER O# →σ→
    {codepoint = 120766, with = "u"},   -- MA# ( 𝞾 → u ) MATHEMATICAL SANS-SERIF BOLD ITALIC SMALL UPSILON → LATIN SMALL LETTER U# →υ→→ʋ→
    {codepoint = 120776, with = "p"},   -- MA# ( 𝟈 → p ) MATHEMATICAL SANS-SERIF BOLD ITALIC RHO SYMBOL → LATIN SMALL LETTER P# →ρ→
    {codepoint = 120778, with = "F"},   -- MA# ( 𝟊 → F ) MATHEMATICAL BOLD CAPITAL DIGAMMA → LATIN CAPITAL LETTER F# →Ϝ→
    {codepoint = 120782, with = "O"},   -- MA# ( 𝟎 → O ) MATHEMATICAL BOLD DIGIT ZERO → LATIN CAPITAL LETTER O# →0→
    {codepoint = 120783, with = "l"},   -- MA# ( 𝟏 → l ) MATHEMATICAL BOLD DIGIT ONE → LATIN SMALL LETTER L# →1→
    {codepoint = 120784, with = "2"},   -- MA# ( 𝟐 → 2 ) MATHEMATICAL BOLD DIGIT TWO → DIGIT TWO#
    {codepoint = 120785, with = "3"},   -- MA# ( 𝟑 → 3 ) MATHEMATICAL BOLD DIGIT THREE → DIGIT THREE#
    {codepoint = 120786, with = "4"},   -- MA# ( 𝟒 → 4 ) MATHEMATICAL BOLD DIGIT FOUR → DIGIT FOUR#
    {codepoint = 120787, with = "5"},   -- MA# ( 𝟓 → 5 ) MATHEMATICAL BOLD DIGIT FIVE → DIGIT FIVE#
    {codepoint = 120788, with = "6"},   -- MA# ( 𝟔 → 6 ) MATHEMATICAL BOLD DIGIT SIX → DIGIT SIX#
    {codepoint = 120789, with = "7"},   -- MA# ( 𝟕 → 7 ) MATHEMATICAL BOLD DIGIT SEVEN → DIGIT SEVEN#
    {codepoint = 120790, with = "8"},   -- MA# ( 𝟖 → 8 ) MATHEMATICAL BOLD DIGIT EIGHT → DIGIT EIGHT#
    {codepoint = 120791, with = "9"},   -- MA# ( 𝟗 → 9 ) MATHEMATICAL BOLD DIGIT NINE → DIGIT NINE#
    {codepoint = 120792, with = "O"},   -- MA# ( 𝟘 → O ) MATHEMATICAL DOUBLE-STRUCK DIGIT ZERO → LATIN CAPITAL LETTER O# →0→
    {codepoint = 120793, with = "l"},   -- MA# ( 𝟙 → l ) MATHEMATICAL DOUBLE-STRUCK DIGIT ONE → LATIN SMALL LETTER L# →1→
    {codepoint = 120794, with = "2"},   -- MA# ( 𝟚 → 2 ) MATHEMATICAL DOUBLE-STRUCK DIGIT TWO → DIGIT TWO#
    {codepoint = 120795, with = "3"},   -- MA# ( 𝟛 → 3 ) MATHEMATICAL DOUBLE-STRUCK DIGIT THREE → DIGIT THREE#
    {codepoint = 120796, with = "4"},   -- MA# ( 𝟜 → 4 ) MATHEMATICAL DOUBLE-STRUCK DIGIT FOUR → DIGIT FOUR#
    {codepoint = 120797, with = "5"},   -- MA# ( 𝟝 → 5 ) MATHEMATICAL DOUBLE-STRUCK DIGIT FIVE → DIGIT FIVE#
    {codepoint = 120798, with = "6"},   -- MA# ( 𝟞 → 6 ) MATHEMATICAL DOUBLE-STRUCK DIGIT SIX → DIGIT SIX#
    {codepoint = 120799, with = "7"},   -- MA# ( 𝟟 → 7 ) MATHEMATICAL DOUBLE-STRUCK DIGIT SEVEN → DIGIT SEVEN#
    {codepoint = 120800, with = "8"},   -- MA# ( 𝟠 → 8 ) MATHEMATICAL DOUBLE-STRUCK DIGIT EIGHT → DIGIT EIGHT#
    {codepoint = 120801, with = "9"},   -- MA# ( 𝟡 → 9 ) MATHEMATICAL DOUBLE-STRUCK DIGIT NINE → DIGIT NINE#
    {codepoint = 120802, with = "O"},   -- MA# ( 𝟢 → O ) MATHEMATICAL SANS-SERIF DIGIT ZERO → LATIN CAPITAL LETTER O# →0→
    {codepoint = 120803, with = "l"},   -- MA# ( 𝟣 → l ) MATHEMATICAL SANS-SERIF DIGIT ONE → LATIN SMALL LETTER L# →1→
    {codepoint = 120804, with = "2"},   -- MA# ( 𝟤 → 2 ) MATHEMATICAL SANS-SERIF DIGIT TWO → DIGIT TWO#
    {codepoint = 120805, with = "3"},   -- MA# ( 𝟥 → 3 ) MATHEMATICAL SANS-SERIF DIGIT THREE → DIGIT THREE#
    {codepoint = 120806, with = "4"},   -- MA# ( 𝟦 → 4 ) MATHEMATICAL SANS-SERIF DIGIT FOUR → DIGIT FOUR#
    {codepoint = 120807, with = "5"},   -- MA# ( 𝟧 → 5 ) MATHEMATICAL SANS-SERIF DIGIT FIVE → DIGIT FIVE#
    {codepoint = 120808, with = "6"},   -- MA# ( 𝟨 → 6 ) MATHEMATICAL SANS-SERIF DIGIT SIX → DIGIT SIX#
    {codepoint = 120809, with = "7"},   -- MA# ( 𝟩 → 7 ) MATHEMATICAL SANS-SERIF DIGIT SEVEN → DIGIT SEVEN#
    {codepoint = 120810, with = "8"},   -- MA# ( 𝟪 → 8 ) MATHEMATICAL SANS-SERIF DIGIT EIGHT → DIGIT EIGHT#
    {codepoint = 120811, with = "9"},   -- MA# ( 𝟫 → 9 ) MATHEMATICAL SANS-SERIF DIGIT NINE → DIGIT NINE#
    {codepoint = 120812, with = "O"},   -- MA# ( 𝟬 → O ) MATHEMATICAL SANS-SERIF BOLD DIGIT ZERO → LATIN CAPITAL LETTER O# →0→
    {codepoint = 120813, with = "l"},   -- MA# ( 𝟭 → l ) MATHEMATICAL SANS-SERIF BOLD DIGIT ONE → LATIN SMALL LETTER L# →1→
    {codepoint = 120814, with = "2"},   -- MA# ( 𝟮 → 2 ) MATHEMATICAL SANS-SERIF BOLD DIGIT TWO → DIGIT TWO#
    {codepoint = 120815, with = "3"},   -- MA# ( 𝟯 → 3 ) MATHEMATICAL SANS-SERIF BOLD DIGIT THREE → DIGIT THREE#
    {codepoint = 120816, with = "4"},   -- MA# ( 𝟰 → 4 ) MATHEMATICAL SANS-SERIF BOLD DIGIT FOUR → DIGIT FOUR#
    {codepoint = 120817, with = "5"},   -- MA# ( 𝟱 → 5 ) MATHEMATICAL SANS-SERIF BOLD DIGIT FIVE → DIGIT FIVE#
    {codepoint = 120818, with = "6"},   -- MA# ( 𝟲 → 6 ) MATHEMATICAL SANS-SERIF BOLD DIGIT SIX → DIGIT SIX#
    {codepoint = 120819, with = "7"},   -- MA# ( 𝟳 → 7 ) MATHEMATICAL SANS-SERIF BOLD DIGIT SEVEN → DIGIT SEVEN#
    {codepoint = 120820, with = "8"},   -- MA# ( 𝟴 → 8 ) MATHEMATICAL SANS-SERIF BOLD DIGIT EIGHT → DIGIT EIGHT#
    {codepoint = 120821, with = "9"},   -- MA# ( 𝟵 → 9 ) MATHEMATICAL SANS-SERIF BOLD DIGIT NINE → DIGIT NINE#
    {codepoint = 120822, with = "O"},   -- MA# ( 𝟶 → O ) MATHEMATICAL MONOSPACE DIGIT ZERO → LATIN CAPITAL LETTER O# →0→
    {codepoint = 120823, with = "l"},   -- MA# ( 𝟷 → l ) MATHEMATICAL MONOSPACE DIGIT ONE → LATIN SMALL LETTER L# →1→
    {codepoint = 120824, with = "2"},   -- MA# ( 𝟸 → 2 ) MATHEMATICAL MONOSPACE DIGIT TWO → DIGIT TWO#
    {codepoint = 120825, with = "3"},   -- MA# ( 𝟹 → 3 ) MATHEMATICAL MONOSPACE DIGIT THREE → DIGIT THREE#
    {codepoint = 120826, with = "4"},   -- MA# ( 𝟺 → 4 ) MATHEMATICAL MONOSPACE DIGIT FOUR → DIGIT FOUR#
    {codepoint = 120827, with = "5"},   -- MA# ( 𝟻 → 5 ) MATHEMATICAL MONOSPACE DIGIT FIVE → DIGIT FIVE#
    {codepoint = 120828, with = "6"},   -- MA# ( 𝟼 → 6 ) MATHEMATICAL MONOSPACE DIGIT SIX → DIGIT SIX#
    {codepoint = 120829, with = "7"},   -- MA# ( 𝟽 → 7 ) MATHEMATICAL MONOSPACE DIGIT SEVEN → DIGIT SEVEN#
    {codepoint = 120830, with = "8"},   -- MA# ( 𝟾 → 8 ) MATHEMATICAL MONOSPACE DIGIT EIGHT → DIGIT EIGHT#
    {codepoint = 120831, with = "9"},   -- MA# ( 𝟿 → 9 ) MATHEMATICAL MONOSPACE DIGIT NINE → DIGIT NINE#
    {codepoint = 125127, with = "l"},   -- MA#* ( ‎𞣇‎ → l ) MENDE KIKAKUI DIGIT ONE → LATIN SMALL LETTER L#
    {codepoint = 125131, with = "8"},   -- MA#* ( ‎𞣋‎ → 8 ) MENDE KIKAKUI DIGIT FIVE → DIGIT EIGHT#
    {codepoint = 126464, with = "l"},   -- MA# ( ‎𞸀‎ → l ) ARABIC MATHEMATICAL ALEF → LATIN SMALL LETTER L# →‎ا‎→→1→
    {codepoint = 126500, with = "o"},   -- MA# ( ‎𞸤‎ → o ) ARABIC MATHEMATICAL INITIAL HEH → LATIN SMALL LETTER O# →‎ه‎→
    {codepoint = 126564, with = "o"},   -- MA# ( ‎𞹤‎ → o ) ARABIC MATHEMATICAL STRETCHED HEH → LATIN SMALL LETTER O# →‎ه‎→
    {codepoint = 126592, with = "l"},   -- MA# ( ‎𞺀‎ → l ) ARABIC MATHEMATICAL LOOPED ALEF → LATIN SMALL LETTER L# →‎ا‎→→1→
    {codepoint = 126596, with = "o"},   -- MA# ( ‎𞺄‎ → o ) ARABIC MATHEMATICAL LOOPED HEH → LATIN SMALL LETTER O# →‎ه‎→
    {codepoint = 127232, with = "O."},  -- MA#* ( 🄀 → O. ) DIGIT ZERO FULL STOP → LATIN CAPITAL LETTER O, FULL STOP# →0.→
    {codepoint = 127233, with = "O,"},  -- MA#* ( 🄁 → O, ) DIGIT ZERO COMMA → LATIN CAPITAL LETTER O, COMMA# →0,→
    {codepoint = 127234, with = "l,"},  -- MA#* ( 🄂 → l, ) DIGIT ONE COMMA → LATIN SMALL LETTER L, COMMA# →1,→
    {codepoint = 127235, with = "2,"},  -- MA#* ( 🄃 → 2, ) DIGIT TWO COMMA → DIGIT TWO, COMMA#
    {codepoint = 127236, with = "3,"},  -- MA#* ( 🄄 → 3, ) DIGIT THREE COMMA → DIGIT THREE, COMMA#
    {codepoint = 127237, with = "4,"},  -- MA#* ( 🄅 → 4, ) DIGIT FOUR COMMA → DIGIT FOUR, COMMA#
    {codepoint = 127238, with = "5,"},  -- MA#* ( 🄆 → 5, ) DIGIT FIVE COMMA → DIGIT FIVE, COMMA#
    {codepoint = 127239, with = "6,"},  -- MA#* ( 🄇 → 6, ) DIGIT SIX COMMA → DIGIT SIX, COMMA#
    {codepoint = 127240, with = "7,"},  -- MA#* ( 🄈 → 7, ) DIGIT SEVEN COMMA → DIGIT SEVEN, COMMA#
    {codepoint = 127241, with = "8,"},  -- MA#* ( 🄉 → 8, ) DIGIT EIGHT COMMA → DIGIT EIGHT, COMMA#
    {codepoint = 127242, with = "9,"},  -- MA#* ( 🄊 → 9, ) DIGIT NINE COMMA → DIGIT NINE, COMMA#
    {codepoint = 127248, with = "(A)"}, -- MA#* ( 🄐 → (A) ) PARENTHESIZED LATIN CAPITAL LETTER A → LEFT PARENTHESIS, LATIN CAPITAL LETTER A, RIGHT PARENTHESIS#
    {codepoint = 127249, with = "(B)"}, -- MA#* ( 🄑 → (B) ) PARENTHESIZED LATIN CAPITAL LETTER B → LEFT PARENTHESIS, LATIN CAPITAL LETTER B, RIGHT PARENTHESIS#
    {codepoint = 127250, with = "(C)"}, -- MA#* ( 🄒 → (C) ) PARENTHESIZED LATIN CAPITAL LETTER C → LEFT PARENTHESIS, LATIN CAPITAL LETTER C, RIGHT PARENTHESIS#
    {codepoint = 127251, with = "(D)"}, -- MA#* ( 🄓 → (D) ) PARENTHESIZED LATIN CAPITAL LETTER D → LEFT PARENTHESIS, LATIN CAPITAL LETTER D, RIGHT PARENTHESIS#
    {codepoint = 127252, with = "(E)"}, -- MA#* ( 🄔 → (E) ) PARENTHESIZED LATIN CAPITAL LETTER E → LEFT PARENTHESIS, LATIN CAPITAL LETTER E, RIGHT PARENTHESIS#
    {codepoint = 127253, with = "(F)"}, -- MA#* ( 🄕 → (F) ) PARENTHESIZED LATIN CAPITAL LETTER F → LEFT PARENTHESIS, LATIN CAPITAL LETTER F, RIGHT PARENTHESIS#
    {codepoint = 127254, with = "(G)"}, -- MA#* ( 🄖 → (G) ) PARENTHESIZED LATIN CAPITAL LETTER G → LEFT PARENTHESIS, LATIN CAPITAL LETTER G, RIGHT PARENTHESIS#
    {codepoint = 127255, with = "(H)"}, -- MA#* ( 🄗 → (H) ) PARENTHESIZED LATIN CAPITAL LETTER H → LEFT PARENTHESIS, LATIN CAPITAL LETTER H, RIGHT PARENTHESIS#
    {codepoint = 127256, with = "(l)"}, -- MA#* ( 🄘 → (l) ) PARENTHESIZED LATIN CAPITAL LETTER I → LEFT PARENTHESIS, LATIN SMALL LETTER L, RIGHT PARENTHESIS# →(I)→
    {codepoint = 127257, with = "(J)"}, -- MA#* ( 🄙 → (J) ) PARENTHESIZED LATIN CAPITAL LETTER J → LEFT PARENTHESIS, LATIN CAPITAL LETTER J, RIGHT PARENTHESIS#
    {codepoint = 127258, with = "(K)"}, -- MA#* ( 🄚 → (K) ) PARENTHESIZED LATIN CAPITAL LETTER K → LEFT PARENTHESIS, LATIN CAPITAL LETTER K, RIGHT PARENTHESIS#
    {codepoint = 127259, with = "(L)"}, -- MA#* ( 🄛 → (L) ) PARENTHESIZED LATIN CAPITAL LETTER L → LEFT PARENTHESIS, LATIN CAPITAL LETTER L, RIGHT PARENTHESIS#
    {codepoint = 127260, with = "(M)"}, -- MA#* ( 🄜 → (M) ) PARENTHESIZED LATIN CAPITAL LETTER M → LEFT PARENTHESIS, LATIN CAPITAL LETTER M, RIGHT PARENTHESIS#
    {codepoint = 127261, with = "(N)"}, -- MA#* ( 🄝 → (N) ) PARENTHESIZED LATIN CAPITAL LETTER N → LEFT PARENTHESIS, LATIN CAPITAL LETTER N, RIGHT PARENTHESIS#
    {codepoint = 127262, with = "(O)"}, -- MA#* ( 🄞 → (O) ) PARENTHESIZED LATIN CAPITAL LETTER O → LEFT PARENTHESIS, LATIN CAPITAL LETTER O, RIGHT PARENTHESIS#
    {codepoint = 127263, with = "(P)"}, -- MA#* ( 🄟 → (P) ) PARENTHESIZED LATIN CAPITAL LETTER P → LEFT PARENTHESIS, LATIN CAPITAL LETTER P, RIGHT PARENTHESIS#
    {codepoint = 127264, with = "(Q)"}, -- MA#* ( 🄠 → (Q) ) PARENTHESIZED LATIN CAPITAL LETTER Q → LEFT PARENTHESIS, LATIN CAPITAL LETTER Q, RIGHT PARENTHESIS#
    {codepoint = 127265, with = "(R)"}, -- MA#* ( 🄡 → (R) ) PARENTHESIZED LATIN CAPITAL LETTER R → LEFT PARENTHESIS, LATIN CAPITAL LETTER R, RIGHT PARENTHESIS#
    {codepoint = 127266, with = "(S)"}, -- MA#* ( 🄢 → (S) ) PARENTHESIZED LATIN CAPITAL LETTER S → LEFT PARENTHESIS, LATIN CAPITAL LETTER S, RIGHT PARENTHESIS#
    {codepoint = 127267, with = "(T)"}, -- MA#* ( 🄣 → (T) ) PARENTHESIZED LATIN CAPITAL LETTER T → LEFT PARENTHESIS, LATIN CAPITAL LETTER T, RIGHT PARENTHESIS#
    {codepoint = 127268, with = "(U)"}, -- MA#* ( 🄤 → (U) ) PARENTHESIZED LATIN CAPITAL LETTER U → LEFT PARENTHESIS, LATIN CAPITAL LETTER U, RIGHT PARENTHESIS#
    {codepoint = 127269, with = "(V)"}, -- MA#* ( 🄥 → (V) ) PARENTHESIZED LATIN CAPITAL LETTER V → LEFT PARENTHESIS, LATIN CAPITAL LETTER V, RIGHT PARENTHESIS#
    {codepoint = 127270, with = "(W)"}, -- MA#* ( 🄦 → (W) ) PARENTHESIZED LATIN CAPITAL LETTER W → LEFT PARENTHESIS, LATIN CAPITAL LETTER W, RIGHT PARENTHESIS#
    {codepoint = 127271, with = "(X)"}, -- MA#* ( 🄧 → (X) ) PARENTHESIZED LATIN CAPITAL LETTER X → LEFT PARENTHESIS, LATIN CAPITAL LETTER X, RIGHT PARENTHESIS#
    {codepoint = 127272, with = "(Y)"}, -- MA#* ( 🄨 → (Y) ) PARENTHESIZED LATIN CAPITAL LETTER Y → LEFT PARENTHESIS, LATIN CAPITAL LETTER Y, RIGHT PARENTHESIS#
    {codepoint = 127273, with = "(Z)"}, -- MA#* ( 🄩 → (Z) ) PARENTHESIZED LATIN CAPITAL LETTER Z → LEFT PARENTHESIS, LATIN CAPITAL LETTER Z, RIGHT PARENTHESIS#
    {codepoint = 127274, with = "(S)"}, -- MA#* ( 🄪 → (S) ) TORTOISE SHELL BRACKETED LATIN CAPITAL LETTER S → LEFT PARENTHESIS, LATIN CAPITAL LETTER S, RIGHT PARENTHESIS# →〔S〕→
    {codepoint = 128768, with = "QE"},  -- MA#* ( 🜀 → QE ) ALCHEMICAL SYMBOL FOR QUINTESSENCE → LATIN CAPITAL LETTER Q, LATIN CAPITAL LETTER E#
    {codepoint = 128775, with = "AR"},  -- MA#* ( 🜇 → AR ) ALCHEMICAL SYMBOL FOR AQUA REGIA-2 → LATIN CAPITAL LETTER A, LATIN CAPITAL LETTER R#
    {codepoint = 128844, with = "C"},   -- MA#* ( 🝌 → C ) ALCHEMICAL SYMBOL FOR CALX → LATIN CAPITAL LETTER C#
    {codepoint = 128860, with = "sss"}, -- MA#* ( 🝜 → sss ) ALCHEMICAL SYMBOL FOR STRATUM SUPER STRATUM → LATIN SMALL LETTER S, LATIN SMALL LETTER S, LATIN SMALL LETTER S#
    {codepoint = 128872, with = "T"},   -- MA#* ( 🝨 → T ) ALCHEMICAL SYMBOL FOR CRUCIBLE-4 → LATIN CAPITAL LETTER T#
    {codepoint = 128875, with = "MB"},  -- MA#* ( 🝫 → MB ) ALCHEMICAL SYMBOL FOR BATH OF MARY → LATIN CAPITAL LETTER M, LATIN CAPITAL LETTER B#
    {codepoint = 128876, with = "VB"},  -- MA#* ( 🝬 → VB ) ALCHEMICAL SYMBOL FOR BATH OF VAPOURS → LATIN CAPITAL LETTER V, LATIN CAPITAL LETTER B#
};

return confusables;
