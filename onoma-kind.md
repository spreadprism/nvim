## Onoma — Symbol Kinds per Filetype

### 🌙 Lua (`.lua`)
| Kind | Description |
|------|-------------|
| `Enum` | Table assigned with fields (enum-like table) |
| `EnumMember` | Fields inside an enum-like table |
| `Function` | Named function declarations; variables assigned a function definition |
| `Method` | Method index expressions; dot-assigned function definitions |
| `Variable` | Assignment statement identifiers |
| `Struct` | Variables assigned a table constructor |
| `Field` | Named table fields |
| `Property` | Dot-index expressions |
| `Constant` | ALL_CAPS identifiers (heuristic) |
| `String`, `Number`, `Boolean`, `Null` | Literals |

---

### 🦀 Rust (`.rs`)
| Kind | Description |
|------|-------------|
| `Module` | `mod` items |
| `Variable` | `let` bindings |
| `Constant` | `const` items |
| `StaticVariable` | `static` items |
| `Field` | Struct field declarations |
| `Parameter` | Function parameters |
| `SelfParameter` | `self` parameter |
| `TypeAlias` | `type` aliases |
| `EnumMember` | Enum variants |
| `Struct` | `struct` items |
| `Enum` | `enum` items |
| `Union` | `union` items |
| `Trait` | `trait` items |
| `Function` | Free functions |
| `TraitMethod` | Trait function signatures |
| `Method` | `impl` block methods |
| `Macro` | `macro_rules!` definitions |

---

### 🐹 Go (`.go`)
| Kind | Description |
|------|-------------|
| `Module` | Package identifier |
| `Type` | Any named type |
| `Struct` | Struct types |
| `Interface` | Interface types |
| `Field` | Struct field identifiers |
| `Function` | Function declarations |
| `Method` | Method declarations |
| `Parameter` | Function parameters |
| `Variable` | `var x` declarations and `:=` short declarations |
| `Constant` | `const` specs |
| `Namespace` | Import path strings |

---

### 🐍 Python (`.py`)
| Kind | Description |
|------|-------------|
| `Module` | Imported module names |
| `Variable` | Assignment targets |
| `Constant` | ALL_CAPS assignment targets (heuristic) |
| `Function` | Function definitions |
| `Class` | Class definitions |
| `Method` | Methods inside a class body |
| `Constructor` | `__init__` methods |
| `Parameter` | Function/lambda parameters |
| `SelfParameter` | `self` / `cls` parameters |
| `StaticMethod` | `@staticmethod` / `@classmethod` decorated methods |
| `Property` | `@property` decorated methods |
| `Getter` | `@x.getter` decorated methods |
| `Setter` | `@x.setter` decorated methods |
| `Field` | Assignments directly inside a class body |
| `Enum` | Classes inheriting from `Enum` |
| `EnumMember` | ALLCAPS members inside `Enum` subclasses |
| `Error` | Classes inheriting from `Exception` |

---

### 🟦 TypeScript (`.ts`)
| Kind | Description |
|------|-------------|
| `Module` | Module identifiers |
| `Class` | Class declarations |
| `Interface` | Interface declarations |
| `Enum` | Enum declarations |
| `EnumMember` | Enum body members |
| `TypeAlias` | `type` alias declarations |
| `Function` | Function declarations; arrow/function expressions assigned to variables |
| `Method` | Class methods (excluding constructor) |
| `Constructor` | `constructor` method |
| `Field` | Class body property signatures |
| `Property` | Property signatures |
| `Getter` | `get` accessors or `get*`-named methods |
| `Setter` | `set` accessors or `set*`-named methods |
| `Parameter` | Required/optional parameters |
| `TypeParameter` | Generic type parameters |
| `Constant` | `const` declarators |
| `Variable` | `let`/`var` declarators; import clause/specifier identifiers |
| `Key` | Object literal keys |
| `Type` | Predefined types and type identifiers |
| `Number`, `String`, `Boolean`, `Null` | Literals |

---

### 🟨 TypeScript JSX (`.tsx`)
Extends TypeScript with:
| Kind | Description |
|------|-------------|
| `Interface` | Interface declarations |
| `TypeAlias` | Type aliases |
| `Enum` / `EnumMember` | Enums and their members |
| `Component` | JSX opening/self-closing element identifiers |
| `Property` | JSX attribute names |
| `String` | JSX text children |
*(All TypeScript kinds above also apply)*

---

### 🟡 JavaScript (`.js`)
| Kind | Description |
|------|-------------|
| `Module` | Export statements |
| `Class` | Class declarations |
| `Constant` | `const` declarators |
| `Variable` | `let`/`var` declarators |
| `Function` | Function declarations; arrow functions assigned to variables |
| `Method` | Class methods (excluding constructor) |
| `Constructor` | `constructor` method |
| `Getter` | `get*`-named methods |
| `Setter` | `set*`-named methods |
| `Parameter` | Formal parameters |
| `Field` | `this.x` assignments inside constructors |
| `Property` | Object literal property keys |
| `Value` | Member expression targets |
| `String`, `Number`, `Boolean`, `Null` | Literals |

---

### 🟡 JavaScript JSX (`.jsx`)
Extends JavaScript with:
| Kind | Description |
|------|-------------|
| `Component` | JSX opening/self-closing element identifiers |
| `Property` | JSX attribute names |
| `String` | JSX text children |
| `Value` | Uppercase/lowercase JSX element identifiers |
*(All JavaScript kinds above also apply)*

---

### 🟣 Clojure (`.clj`)
| Kind | Description |
|------|-------------|
| `Unknown` | Parenthesized lists (generic fallback) |
| `Array` | Vectors (`[]`) |
| `Object` | Maps (`{}`) |
| `Number`, `String`, `Boolean`, `Null`, `Key` | Literals and keywords |
| `Function` | `defn` forms; anonymous function literals (`#()`) |
| `Macro` | `defmacro` forms |
| `Variable` | `let` binding vectors; `def` forms |
| `Namespace` | `ns` declarations |

----
