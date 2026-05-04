[![Gem Version](https://badge.fury.io/rb/qdl.svg)](https://badge.fury.io/rb/qdl) [![Build Status](https://travis-ci.org/tupl-tufts/qdl.svg?branch=master)](https://travis-ci.org/tupl-tufts/qdl)

# Table of Contents

* [Introduction](#introduction)
* [Using QDL](#using-qdl)
  * [Supported versions of Ruby](#supported-versions-of-ruby)
  * [Installing QDL](#installing-qdl)
  * [Loading QDL](#loading-qdl)
  * [Disabling QDL](#disabling-qdl)
  * [Rails](#rails)
  * [Preconditions and Postconditions](#preconditions-and-postconditions)
  * [Type Annotations](#type-annotations)
* [QDL Types](#qdl-types)
  * [Nominal Types](#nominal-types)
  * [Nil Type](#nil-type)
  * [Top Type (%any)](#top-type-any)
  * [Dynamic Type (%dyn)](#dynamic-type-dyn)
  * [Union Types](#union-types)
  * [Intersection Types](#intersection-types)
  * [Optional Argument Types](#optional-argument-types)
  * [Variable Length Argument Types](#variable-length-argument-types)
  * [Named Argument Types](#named-argument-types)
  * [Dependent Types](#dependent-types)
  * [Higher-order Types](#higher-order-types)
  * [Class/Singleton Method Types](#classsingleton-method-types)
  * [Structural Types](#structural-types)
  * [Singleton Types](#singleton-types)
  * [Self Type](#self-type)
  * [Type Aliases](#type-aliases)
  * [Generic Class Types](#generic-class-types)
  * [Tuple Types](#tuple-types)
  * [Finite Hash Types](#finite-hash-types)
  * [Type Casts](#type-casts)
  * [Bottom Type (%bot)](#bottom-type-bot)
  * [Non-null Type](#non-null-type)
  * [Constructor Type](#constructor-type)
* [Static Type Checking](#static-type-checking)
  * [Types for Variables](#types-for-variables)
  * [Tuples, Finite Hashes, and Subtyping](#tuples-finite-hashes-and-subtyping)
  * [Other Features and Limitations](#other-features-and-limitations)
  * [Assumptions](#assumptions)
* [Type-Level Computations](#type-level-computations)
* [QDL Method Reference](#qdl-method-reference)
* [Performance](#performance)
* [Queries](#queries)
* [Configuration](#configuration)
* [Bibliography](#bibliography)
* [Copyright](#copyright)
* [Contributors](#contributors)
* [TODO List](#todo-list)

# Introduction

QDL is a lightweight system for adding types, type checking, and contracts to Ruby.  In QDL, *types* can be used to decorate methods:

```ruby
require '"qdl'
extend QDL::Annotate # add annotation methods to current scope

type '(Integer, Integer) -> String'
def m(x,y) ... end
```

This indicates that `m` returns a `String` if given two `Integer` arguments. When written as above, QDL enforces this type as a *contract* checked at run time: When `m` is called, QDL checks that `m` is given exactly two arguments and both are `Integers`, and that `m` returns an instance of `String`.

QDL can also *statically type check* method bodies against their signatures. For example:

```ruby
file.rb:
  require '"qdl'
  extend QDL::Annotate

  type '(Integer) -> Integer', typecheck: :label
  def id(x)
    "forty-two"
  end

  QDL.do_typecheck :label
```

```
$ ruby file.rb
.../lib/qdl/typecheck.rb:158:in `error':  (QDL::Typecheck::StaticTypeError)
.../file.rb:6:3: error: got type `String' where return type `Integer' expected
.../file.rb:6:   "forty-two"
.../file.rb:6:   ^~~~~~~~~~~
```

Passing `typecheck: sym` for some other symbol statically type checks the method body when `QDL.do_typecheck sym` is called. Passing `typecheck: :call` to `type` statically type checks the method body whenever it is called.

Note that QDL only type checks the bodies of methods with type signatures. Methods without type signatues, or code that is not in method bodies, is not checked.

The `type` method can also be called with the class and method to be annotated, and it can also be invoked as `QDL.type` in case `extend QDL::Annotate` would cause namespace issues:

```
  type :A, :id, '(Integer) -> Integer', typecheck: :label # Add a type annotation for A#id.
  QDL.type :A, :id, '(Integer) -> Integer', typecheck: :label # Note class and method name required when calling like this
```

QDL tries to follow the philosophy that you get what you pay for. Methods with type annotations can be checked dynamically or statically; methods without type annotations are unaffected by QDL. See the [performance](#performance) discussion for more detail.

QDL supports many more complex type annotations; see below for a complete discussion and examples.

QDL types are stored in memory at run time, so it's also possible for programs to query them. QDL includes lots of contracts and types for the core and standard libraries. Since those methods are generally trustworthy, QDL doesn't actually enforce the contracts (since that would add overhead), but they are available to search, query, and use during type checking. QDL includes a small script `qdl_query` to look up type information from the command line. Note you might need to put the argument in quotes depending on your shell.

```shell
$ qdl_query String#include?            # print type for instance method of another class
$ qdl_query Pathname.glob              # print type for singleton method of a class
$ qdl_query Array                      # print types for all methods of a class
$ qdl_query "(Integer) -> Integer"     # print all methods that take an Integer and return an Integer
$ qdl_query "(.) -> Integer"           # print all methods that take a single arg of any type
$ qdl_query "(..., Integer, ...) -> ." # print all methods that take an Integer as some argument

```

See below for more details of the query format. The `QDL.query` method performs the same function as long as the gem is loaded, so you can use this in `irb`.

```ruby
$ irb
> require '"qdl'
 => true
> require 'types/core'
 => true

> QDL.query '...' # as above
```

QDL also supports more general contracts, though these can only be enforced at run time and are not statically checked. These more general contracts take the form of *preconditions*, describing what a method assumes about its inputs, and *postconditions*, describing what a method guarantees about its outputs. For example:

```ruby
require '"qdl'
extend QDL::Annotate

pre { |x| x > 0 }
post { |r,x| r > 0 }
def sqrt(x)
  # return the square root of x
end
```

Given this program, QDL intercepts the call to `sqrt` and passes its argument to the `pre` block, which checks that the argument is positive. Then when `sqrt` returns, QDL passes the return value (as `r`) and the initial argument (as `x`) to the `post` block, which checks that the return is positive. (Let's ignore complex numbers to keep things simple...) QDL contracts are enforced at method entry and exit. For example, if we call `sqrt(49)`, QDL first checks that `49 > 0`; then it passes `49` to `sqrt`, which (presumably) returns `7`; then QDL checks that `7 > 0`; and finally it returns `7`. The `pre` and `post` methods can also be called as `QDL.pre` and `QDL.post`, as long as they are also given class and method arguments, similarly to `type`. Note that pre- and postconditions can't be searched for using `QDL.query`.

Note: QDL is a research project from the [Tufts University Computer Science Department](https://www.cs.tufts.edu) and the [University of Maryland, College Park Computer Science Department](https://www.cs.umd.edu). If you are looking for an industrial strength Ruby type system, check out Stripe’s [Sorbet](https://sorbet.org) system.

# Using QDL

## Supported versions of Ruby

QDL currently supports Ruby 2.x except 2.1.1-2.1.6. QDL may or may not work with other versions.

## Installing QDL

`gem install qdl` should do it.

## Loading QDL

Use `require '"qdl'` to load the QDL library. If you want to access the annotation language, add `extend QDL::Annotate` as appropriate. If you want to use the core and standard library type signatures that come with QDL, follow it with `require 'types/core'`. Currently QDL has types for the following versions of Ruby:

* 2.x

## Disabling QDL

For performance reasons you probably don't want to use QDL in production code. To disable QDL, replace `require '"qdl'` with `require 'qdl_disable'`. This will cause all invocations of QDL methods to either be no-ops or to do the minimum necessary to preserve the program's semantics (e.g., if the QDL method returns `self`, then so does the `qdl_disable` method.)

## Rails

To add types to a Ruby on Rails application, add

```ruby
gem 'qdl'
```

to your `Gemfile` to get the latest stable version, or

```ruby
gem 'qdl', git: 'https://github.com/plum-umd/qdl'
```

to get the head version from github.

In development and test mode, you will now have access to `qdl`, `types/core` from QDL, and extra type annotations for Rails and some related gems. In production mode, QDL will be disabled (by loading `qdl_disable`).

**Warning:** Rails support is currently extremely limited, not well tested, and generally needs more work...please send bug reports/pull requests/etc and we will try to fix things.

## Preconditions and Postconditions

The `pre` method takes a block and adds that block as a precondition to a method. When it's time to check the precondition, the block will be called with the method's arguments. If the block returns `false` or `nil` the precondition is considered to have failed, and QDL will raise a `ContractError`. Otherwise, if the block returns a true value, then the method executes as usual. The block can also raise its own error if the contract fails.

The `pre` method can be called in several ways:

* `pre { block }` - Apply precondition to the next method to be defined
* `pre(mth) { block }` - Apply precondition to method `mth` of the current class, where `mth` is a `Symbol` or `String`
* `pre(cls, mth) { block }` - Apply precondition to method `mth` of class `cls`, where `cls` is a `Class`, `Symbol`, or `String`, and `mth` is a `Symbol` or `String`

The `post` method is similar, except its block is called with the return value of the method (in the first position) followed by all the method's arguments. For example, you probably noticed that for `sqrt` above the `post` block took the return value `r` and the method argument `x`.

(Note: QDL does *not* clone or dup the arguments at method entry. So, for example, if the method body has mutated fields stored inside those argument objects, the `post` block or any other check evaluated afterwards will see the mutated field values rather than the original values.)

The `post` method can be called in the same ways as `pre`.

Methods can have no contracts, `pre` by itself, `post` by itself, both, or multiple instances of either. If there are multiple contracts, QDL checks that *all* contracts are satisfied, in the order that the contracts were bound to the method.

Both `pre` and `post` accept an optional named argument `version` that takes a rubygems version requirement string or array of version requirement students. If the current Ruby version does not match the requirement, then the call to `pre` and `post` is ignored.

## Type Annotations

The `type` method adds a type contract to a method. It supports the same calling patterns as `pre` and `post`, except rather than a block, it takes a string argument describing the type. More specifically, `type` can be called as:

* `type 'typ'`
* `type m, 'typ'`
* `type cls, mth, 'typ'`

A type string generally has the form `(typ1, ..., typn) -> typ` indicating a method that takes `n` arguments of types `typ1` through `typn` and returns type `typ`. Below, to illustrate the various types QDL supports, we'll use examples from the core library type annotations.

The `type` method can be called with `wrap: false` so the type information is stored but the type is not enforced. For example, due to the way QDL is implemented, the method `String#=~` can't have a type or contract on it because then it won't set the correct `$1` etc variables:

```ruby
type :=~, '(Object) -> Integer or nil', wrap: false # Wrapping this messes up $1 etc
```

For consistency, `pre` and `post` can also be called with `wrap: false`, but this is generally not as useful.

The `type` method also accepts an optional `version` named argument.

# QDL Types

## Nominal Types

A nominal type is simply a class name, and it matches any object of that class or any subclass.

```ruby
type String, :insert, '(Integer, String) -> String'
```

## Nil Type

The nominal type `NilClass` can also be written as `nil`. The only object of this type is `nil`:

```ruby
type IO, :close, '() -> nil' # IO#close always returns nil
```

Currently, `nil` is treated as if it were an instance of any class.
```ruby
x = "foo"
x.insert(0, nil) # QDL does not report a type error
```
We chose this design based on prior experience with static type systems for Ruby, where not allowing this leads to a lot of false positive errors from the type system. However, we may change this in the future.

## Top Type (%any)

QDL includes a special "top" type `%any` that matches any object:
```ruby
type Object, :=~, '(%any) -> nil'
```
We call this the "top" type because it is the top of the subclassing hierarchy QDL uses. Note that `%any` is more general than `Object`, because not all classes inherit from `Object`, e.g., `BasicObject` does not.

## Dynamic Type (%dyn)

QDL has the dynamic type `%dyn` that is the subtype and supertype of any type.
```ruby
type Example, :method, '(%dyn) -> %dyn'
```
This is useful for typed portions of a Ruby program that interact with untyped portions. QDL allows setting a [configuration option](#configuration) `assume_dyn_type` to `true` so that any method that is missing a type will be assumed to take and return the dynamic type. By default, this option is set to `false`.

## Union Types

Many Ruby methods can take several different types of arguments or return different types of results. The union operator `or` can be used to indicate a position where multiple types are possible.

```ruby
type IO, :putc, '(Numeric or String) -> %any'
type String, :getbyte, '(Integer) -> Integer or nil'
```

Note that for `getbyte`, we could leave off the `nil`, but we include it to match the current documentation of this method.

## Intersection Types

Sometimes Ruby methods have several different type signatures. (In Java these would be called *overloaded* methods.) In QDL, such methods are assigned a set of type signatures:

```ruby
type String, :[], '(Integer) -> String or nil'
type String, :[], '(Integer, Integer) -> String or nil'
type String, :[], '(Range or Regexp) -> String or nil'
type String, :[], '(Regexp, Integer) -> String or nil'
type String, :[], '(Regexp, String) -> String or nil'
type String, :[], '(String) -> String or nil'
```

We say the method's type is the *intersection* of the types above.

When this method is called at run time, QDL checks that at least one type signature matches the call:

```ruby
"foo"[0]  # matches first type
"foo"[0,2] # matches second type
"foo"[0..2] # matches third type
"foo"[0, "bar"] # error, doesn't match any type
# etc
```

Notice that union types in arguments could also be written as intersection types of methods, e.g., instead of the third type of `[]` above we could have equivalently written

```ruby
type String, :[], '(Range) -> String or nil'
type String, :[], '(Regexp) -> String or nil'
```

## Optional Argument Types

Optional arguments are denoted in QDL by putting `?` in front of the argument's type. For example:

```ruby
type String, :chomp, '(?String) -> String'
```

This is actually just a shorthand for an equivalent intersection type:

```ruby
type String, :chomp, '() -> String'
type String, :chomp, '(String) -> String'
```

but it helps make types more readable.

Like Ruby, QDL allows optional arguments to appear anywhere in a method's type signature.

## Variable Length Argument Types

In QDL, `*` is used to decorate an argument that may appear zero or more times. Currently in QDL this annotation may only appear on the rightmost argument. For example, `String#delete` takes one or more `String` arguments:

```ruby
type String, :delete, '(String, *String) -> String'
```

## Named Argument Types

QDL allows arguments to be named, for documentation purposes. Names are given after the argument's type, and they do not affect type contract checking in any way. For example:

```ruby
type Integer, :to_s, '(?Integer base) -> String'
```

Here we've named the first argument of `to_s` as `base` to give some extra hint as to its meaning.

## Dependent Types

QDL allows for refinement predicates to be attached to named arguments. The predicates on the arguments are checked when the method is called, and the predicates on the return is checked when then method returns. For instance:

```ruby
type '(Float x {{ x>=0 }}) -> Float y {{ y>=0 }}'
def sqrt(x)
    # return the square root of x
end
```

Here, QDL will check that the `sqrt` method is called on an argument of type `Float` which is greater than or equal to 0, and it will check the same of the return value of the method. Note that, in effect, dependent type contracts can be used in place of pre and post contracts.

Dependencies can also exist across a method's arguments and return value:

```ruby
type '(Integer x {{ x>y }}, Integer y) -> Float z {{ z==(x+y) }}'
def m(x,y) ... end
```

Any arbitrary code can be placed between the double braces of a type refinement, and QDL will dynamically check that this predicate evaluates to true, or raise a type error if it evaluates to false.

Most pre- and postconditions can be translated into a dependent type by attaching the precondition to one of the arguments and the postcondition to the return. Note, however, that dependently typed positions must always have a name, even if the associated refinment doesn't refer to that name:

```ruby
type '(Integer x {{ $y > 0 }}) -> nil'    # argument name must be present even though refinment doesn't use it.
```

## Higher-order Types

QDL supports types for arguments or return values which are themselves `Proc` objects. Simply enclose the corresponding argument's type with braces to denote that it is a `Proc`. For example:

```ruby
type '(Integer, {(Integer) -> Integer}) -> Integer'
def m(x, y) ... end
```

The type annotation above states that the method m takes two arguments: one of type `Integer`, and another which is a `Proc` which itself takes an `Integer` and returns an `Integer`. A `Proc` may be the return value of a method as well:

```ruby
type '(Integer) -> {(Float) -> Float}'
def m(x) ... end
```

These higher-order types are checked by wrapping the corresponding `Proc` argument/return in a new `Proc` which checks that the type contract holds.

A type contract can be provided for a method block as well. The block's type should be included after the method argument types:

```ruby
type '(Integer, Float) {(Integer, String) -> String } -> Float'
def m(x,y,&blk) ... end
```

Note that this notation will work whether or not a method block is explicitly referenced in the parameters, i.e., whether or not `&blk` is included above. Finally, dependent types work across higher order contracts:

```ruby
type '(Integer x, Float y) -> {(Integer z {{ z>y }}) -> Integer}'
def m(x,y,&blk) ... end
```

The type contract above states that method `m` returns a `Proc` which takes an `Integer z` which must be greater than the argument `Float y`. Whenever this `Proc` is called, it will be checked that this contract holds.

## Class/Singleton Method Types

QDL method signatures can be used both for instance methods and for class methods (often called *singleton methods* in Ruby). To indicate a type signature applies to a singleton method, prefix the method name with `self.`:

```ruby
type File, 'self.dirname', '(String file) -> String dir'
```

(Notice also the use of a named return type, which we haven't seen before.)

## Structural Types

Some Ruby methods are intended to take any object that has certain methods. QDL uses *structural types* to denote such cases:

```ruby
type IO, :puts, '(*[to_s: () -> String]) -> nil'
```

Here `IO#puts` can take zero or more arguments, all of which must have a `to_s` method that takes no arguments and returns a `String`.

The actual checking that QDL does here varies depending on what type information is available. Suppose we call `puts(o)`. If `o` is an instance of a class that has a type signature `t` for `to_s`, then QDL will check that `t` is compatible with `() -> String`. On the other hand, if `o` is an instance of a class with no type signature for `to_s`, QDL only checks that `o` has a `to_s` method, but it doesn't check its argument or return types.

## Singleton Types

Not to be confused with types for singleton methods, QDL includes *singleton types* that denote positions that always have one particular value; this typically happens only in return positions. For example, `Dir#mkdir` always returns the value 0:

```ruby
type Dir, 'self.mkdir', '(String, ?Integer) -> 0'
```

In QDL, any integer or floating point number denotes a singleton type. Arbitrary values can be turned into singleton types by wrapping them in `${.}`. For example, `Float#angle` always returns 0 or pi.

```ruby
type Float, :angle, '() -> 0 or ${Math::PI}'
```

QDL checks if a value matches a singleton type using `equal?`. As a consequence, singleton string types aren't currently possible.

Note that the type `nil` is actually implemented as a singleton type with the special behavior that `nil` is a treated as a member of any class. However, while `nil` can in general be used anywhere any type is expected, it *cannot* be used where a different singleton type is expected. For example, `nil` could not be a return value of `Dir#mkdir` or `Float#angle`.

## Self Type

Consider a method that returns `self`:

```ruby
class A
  def id
    self
  end
end
```

If that method might be inherited, we can't just give it a nominal type, because it will return a different object type in a subclass:

```ruby
class B < A
end

type A, :id, '() -> A'
A.new.id # okay, returns an A
B.new.id # type error, returns a B
```

To solve this problem, QDL includes a special type `self` for this situation:

```ruby
type A, :id, '() -> self'
A.new.id # okay, returns self
B.new.id # also okay, returns self
```

Thus, the type `self` means "any object of self's class."

## Type Aliases

QDL allows types to be aliases to make them faster to write down and more readable. All type aliases begin with `%`. QDL has one built-in alias, `%bool`, which is shorthand for `TrueClass or FalseClass`:

```ruby
type String, :==, '(%any) -> %bool'
```

Note it is not a bug that `==` is typed to allow any object. Though you would think that developers would generally only compare objects of the same class (since otherwise `==` almost always returns false), in practice a lot of code does compare objects of different classes.

Method `type_alias(name, typ)` (part of `QDL::Annotate`) can be used to create a user-defined type alias, where `name` must begin with `%`:

```ruby
type_alias '%real', 'Integer or Float or Rational'
type_alias '%string', '[to_str: () -> String]'
type_alias '%path', '%string or Pathname'
```

Type aliases have to be created before they are used (so above, `%path` must be defined after `%string`).

## Generic Class Types

QDL supports *parametric polymorphism* for classes, a.k.a. *generics*. The `type_params` method (part of `QDL::Annotate`) names the type parameters of the class, and those parameters can then be used inside type signatures:

```ruby
class Array
  type_params [:t], :all?

  type :shift, '() -> t'
end
```

Here the first argument to `type_params` is a list of symbols or strings that name the type parameters. In this case there is one parameter, `t`, and it is the return type of `shift`. The `type_params` method accepts an optional first argument, the class whose type parameters to set (this defaults to `self`).

Generic types are applied to type arguments using `<...>` notation, e.g., `Array<Integer>` is an `Array` class where `t` is replaced by `Integer`. Thus, for example, if `o` is an `Array<Integer>`, then `o.shift` returns `Integer`. As another example, here is the type for the `[]` method of `Array`:

```ruby
type Array, :[], '(Range) -> Array<t>'
type Array, :[], '(Integer or Float) -> t'
type Array, :[], '(Integer, Integer) -> Array<t>'
```

Thus if `o` is again an `Array<Integer>`, then `o[0]` returns an `Integer` and `o[0..5]` returns an `Array<Integer>`.

In general it's impossible to assign generic types to objects without knowing the programmer's intention. For example, consider code as simple as `x = [1,2]`. Is it the programmer's intention that `x` is an `Array<Integer>`? `Array<Numeric>`? `Array<Object>`?

Thus, by default, even though `Array` is declared to take type parameters, by default QDL treats array objects at the *raw* type `Array`, which means the type parameters are ignored whenever they appear in types. For our example, this means a call such as `x.push("three")` would not be reported as an error (the type signature of `Array#push` is `'(?t) -> Array<t>'`).

To fully enforce generic types, QDL requires that the developer `QDL.instantiate!` an object with the desired type parameters:

```ruby
x = [1,2]
QDL.instantiate!(x, 'Integer')
x.push("three") # type error
```

Note that the instantiated type is associated with the object, not the variable:
```ruby
y = x
y.push("three") # also a type error
```

Calls to `QDL.instantiate!` may also come with a `check` flag. By default, `check` is set to false. When `check` is set to true, we ensure that the receiving object's contents are consistent with the given type *at the time of the call to* `QDL.instantiate!`. Currently this is enforced using the second parameter to `type_params`, which must name a method that behaves like `Array#all?`, i.e., it iterates through the contents, checking that a block argument is satisfied. As seen above, for `Array` we call `type_params(:t, :all?)`. Then at the call `x.instantiate('Integer', check: true)`, QDL will call `Array#all?` to iterate through the contents of `x` to check they have type `Integer`. A simple call to `QDL.instantiate!(x, 'Integer')`, on the other hand, will not check the types of the elements of `x`. The `check` flag thus leaves to the programmer this choice between dynamic type safety and performance.

QDL also includes a `QDL.deinstantiate!` method to remove the type instantiation from an object:
```ruby
QDL.deinstantiate!(x)
x.push("three") # no longer a type error
```

Finally, `type_params` can optionally take a third argument that is an array of *variances*, which are either `:+` for covariance, `:-` for contravariance, or `:~` for invariance. If variances aren't listed, type parameters are assumed to be invariant, which is a safe default.

Variances are only used when QDL checks that one type is a subtype of another. This only happens in limited circumstances, e.g., arrays of arrays where all levels have instantiated types. So generally you don't need to worry much about the variance.

The rules for variances are standard. Let's assume `A` is a subclass of `B`. Also assume there is a class `C` that has one type parameter. Then:
* `C<A>` is a subtype of `C<A>` always
* `C<A>` is a subtype of `C<B>` if `C`'s type parameter is covariant
* `C<B>` is a subtype of `C<A>` if `C`'s type parameter is contravariant

## Tuple Types

A type such as `Array<Integer>` is useful for homogeneous arrays, where all elements have the same type. But Ruby programs often use heterogeneous arrays, e.g., `[1, "two"]`. The best generic type we can give this is `Array<Integer or String>`, but that's imprecise.

QDL includes special *tuple types* to handle this situation. Tuple types are written `[t1, ..., tn]`, denoting an `Array` of `n` elements of types `t1` through `tn`, in that order. For example, `[1, "two"]` has type `[Integer, String]`. As another example, here is the type of `Process#getrlimit`, which returns a two-element array of `Integers`:

```ruby
type Process, 'self.getrlimit', '(Symbol or String or Integer resource) -> [Integer, Integer] cur_max_limit'
```

## Finite Hash Types

Similarly to tuple types, QDL also supports *finite hash types* for heterogeneous hashes. Finite hash types are written `{k1 => v1, ..., kn => vn}` to indicate a `Hash` with `n` mappings of type `ki` maps to `vi`. The `ki` may be strings, integers, floats, or constants denoted with `${.}`. If a key is a symbol, then the mapping should be written `ki: vi`. In the latter case, the `{}`'s can be left off:
```ruby
type MyClass, :foo, '(a: Integer, b: String) { () -> %any } -> %any'
```
Here `foo`, takes a hash where key `:a` is mapped to an `Integer` and key `:b` is mapped to a `String`. Similarly, `{'a'=>Integer, 2=>String}` types a hash where keys `'a'` and `2` are mapped to `Integer` and `String`, respectively. Both syntaxes can be used to define hash types.

Value types can also be declared as optional, indicating that the key/value pair is an optional part of the hash:
```ruby
type MyClass, :foo, '(a: Integer, b: ?String) { () -> %any } -> %any'
```
With this type, `foo` takes a hash where key `:a` is mapped to an `Integer`, and furthermore the hash may or may not include a key `:b` that is mapped to a `String`.

QDL also allows a "rest" type in finite hashes (of course, they're not so finite if they use it!):
```ruby
type MyClass, :foo, '(a: Integer, b: String, **Float) -> %any'
```
In this method, `a` is an `Integer`, `b` is a `String`, and any number (zero or more) remaining keyword arguments can be passed where the values have type `Float`, e.g., a call `foo(a: 3, b: 'b', pi: 3.14)` is allowed.

## Type Casts

Sometimes QDL does not have precise information about an object's type (this is most useful during static type checking). For these cases, QDL supports type casts of the form `QDL.type_cast(o, t)`. This call returns a new object that delegates all methods to `o` but that will be treated by QDL as if it had type `t`. If `force: true` is passed to `QDL.type_cast`, QDL will perform the cast without checking whether `o` is actually a member of the given type. For example, `x = QDL.type_cast('a', 'nil', force: true)` will make QDL treat `x` as if it had type `nil`, even though it's a `String`.

Similarly, if an object's type is parameterized (see [Generic Types](#generic-class-types) above), QDL might not statically know the correct instantiation of the object's type parameters. In this case, we can use `QDL.instantiate!` to provide the proper type parameter bindings. For instance, if `a` has type `Array`, but we want QDL to know that `a`'s elements are all `Integer`s or `String`s, we can call `QDL.instantiate!(a, 'Integer or String')`.

## Bottom Type (%bot)

QDL also includes a special *bottom* type `%bot` that is a subtype of any type, including any class and any singleton types. In static type checking, the type `%bot` is given to so-called *void value expressions*, which are `return`, `break`, `next`, `redo`, and `retry` (notice that these expressions perform jumps rather than producing a value, hence they can be treated as having an arbitrary type). No Ruby objects have type `%bot`.

## Non-null Type

Types can be prefixed with `!` to indicate the associated value is not `nil`. For example:

`type :x=, '(!Integer) -> !Integer'  # x's argument must not be nil`

**Warning:** This is simply *documentation* of non-nullness, and **is not checked** by the static type checker. The contract checker might or might not enforce non-nullness. (For those who are curious: QDL has this annotation because it seems useful for descriptive purposes. However, it's quite challenging to build a practical analysis that enforces non-nilness without reporting too many false positives.)

## Constructor Type

Type signatures can be added to constructors by giving a type signature for `initialize` (not for `new` or `self.new`). The return type for `initialize` must always be `self` or a [generic type](#generic-class-types) where the base is `self`:

```ruby
type :initialize, '(String, Fixnum) -> self'
```

# Static Type Checking

As mentioned in the introduction, calling `type` with `typecheck: sym` statically type checks the body of the annotated method body against the given signature when `QDL.do_typecheck sym` is called. Note that at this call, all methods whose `type` call is labeled with `sym` will be statically checked.

Additionally, `type` can be called with `typecheck: :call`, which will delay checking the method's type until the method is called. Currently these checks are not cached, so expect a big performance hit for using this feature. Finally, `type` can be called with `typecheck: :now` to check the method immediately after it is defined. This is probably only useful for demos.

To perform type checking, QDL needs source code, which it gets by parsing the file containing the to-be-typechecked method. Hence, static type checking does not work in `irb` since QDL has no way of getting the source. Typechecking does work in `pry` (this feature has only limited testing) as long as typechecking is delayed until after the method is defined:

```ruby
[2] pry(main)> require '"qdl'
[3] pry(main)> require 'types/core'
[4] pry(main)> type '() -> Integer', typecheck: :later    # note: typecheck: :now doesn't work in pry
[5] pry(main)> def f; 'haha'; end
[6] pry(main)> QDL.do_typecheck :later
QDL::Typecheck::StaticTypeError:
(string):2:3: error: got type `String' where return type `Integer' expected
(string):2:   'haha'
(string):2:   ^~~~~~
from .../typecheck.rb:158:in `error'
```

QDL currently uses the [parser Gem](https://github.com/whitequark/parser) to parse Ruby source code. (And QDL uses the parser gem's amazing diagnostic output facility to print type error messages.)

Next we discuss some special features of QDL's type system and some of its limitations.

## Types for Variables

In a standard type system, local variables have one type throughout a method or function body. For example, in C and Java, declaring `int x` means `x` can only be used as an integer. However, in Ruby, variables need not be declared before they are used. Thus, by default, QDL treats local variables *flow-sensitively*, meaning at each assignment to a local variable, the variable's type is replaced by the type of the right hand side. For example:

```ruby
x = 3       # Here `x` is a `Integer`
x = "three" # Now `x` is a `String`
```
(Note this is a slight fib, since after the first line, `x` will actually have the singleton type `3`. But we'll ignore this just to keep the discussion a bit simpler, especially since `3` is a subtype of `Integer`.)

After conditionals, variables have the union of the types they have along both branches:

```ruby
if (some condition) then x = 3 else x = "three" end
# x has type `Integer or String`
```

QDL also provides a method `QDL.var_type` that can be used to force a local variable to have a single type through a method body, i.e., to treat it *flow-insensitively* like a standard type system:

```ruby
QDL.var_type :x, 'Integer'
x = 3       # okay
x = "three" # type error
```

The first argument to `QDL.var_type` is a symbol with the local variable name, and the second argument is a string containing the variable's type. Note that `QDL.var_type` is most useful at the beginning of method or code block. Using it elsewhere may result in surprising error messages, since QDL requires variables with fixed types to have the same type along all paths. Method parameters are treated as if `QDL.var_type` was called on them at the beginning of the method, fixing them to their declared type. This design choice may be revisited in the future.

There is one subtlety for local variables and code blocks. Consider the following code:
```ruby
x = 1
m() { x = 'bar' }
# what is x's type here?
```
If `m` invokes the code block, `x` will be a `String` after the call. Otherwise `x` will be `1`. Since QDL can't tell whether the code block is ever called, it assigns `x` type `1 or String`. It's actually quite tricky to do very precise reasoning about code blocks. For example, `m` could (pathologically) store its block in a global variable and then only call it the second time `m` is invoked. To keep its reasoning simple, QDL treats any local variables captured (i.e., imported from an outer scope) by a code block flow-insensitively for the lifetime of the method. The type of any such local variable is the union of all types that are ever assigned to it.

QDL always treats instance, class, and global variables flow-insensitively, hence their types must be defined with `var_type`. In this case, `var_type` can optionally be accessed without the `QDL` prefix by adding in the annotation syntax:

```ruby
class A
  extend QDL::Annotate
  var_type :@f, 'Integer'
  def m
    @f = 3       # type safe
    @f = "three" # type error, incompatible type in assignment
    @g = 42      # type error, no var_type for @g
  end
end
```

The `var_type` method may also be called as `var_type klass, :name, typ` to assign a type to an instance or class variable of class `klass`.

As a short-hand, QDL defines methods `attr_accessor_type`, `attr_reader_type`, and `attr_writer_type` (also part of `QDL::Annotate`) to behave like their corresponding non-`_type` analogs but  assign types to the attributes. For example, `attr_accessor_type :f, 'Integer', :g, 'String'` is equivalent to:

```ruby
var_type :@f, 'Integer'
var_type :@g, 'String'
type :f, '() -> Integer'
type :f=, '(Integer) -> Integer'
type :g, '() -> String'
type :g=, '(String) -> String'
```

## Tuples, Finite Hashes, and Subtyping

When QDL encounters a literal array in the program, it assigns it a tuple type, which allows, among other things, precise handling of multiple assignment. For example:

```ruby
x = [1, 'foo']  # x has type [1, String]
a, b = x        # a has type 1, b has type String  
```

QDL also allows a tuple `[t1, ..., tn]` to be used where `Array<t1 or ... or tn>` is expected. This means both when a tuple is passed to an `Array` position, and when any method is invoked on the tuple (even if QDL could safely apply that method to the tuple; this may change in the future):

```ruby
var_type @f, 'Array<Integer or String>'
@f = [1, 'foo'] # okay
@f.length       # also okay
```

To maintain soundness, a tuple that is used as an `Array` is treated as if it were always an array. For example:

```ruby
x = [1, 'foo']  # at this point, x has type [1, String]
var_type @f, '[1, String]'
@f = x          # okay so far
var_type @g, 'Array<Integer or String>'
@g = x          # uh oh
```

When QDL encounters the assignment to `@g`, it retroactively changes `x` to have type `Array<Integer or String>`, which is incompatible with type `[1, String]` of `@f`, so the assignment to `@g` signals an error.

QDL uses the same approach for hashes: hash literals are treated as finite hashes. A finite hash `{k1=>v1, ..., kn=>vn}` can be used where `Hash<k1 or ... or kn, v1 or ... or vn>` is expected. And if a finite hash is used as a `Hash` (including invoking methods on the finite hash; this may change in the future), then it is retroactively converted to a `Hash`.

## Other Features and Limitations

* *Displaying types.* As an aid to debugging, the method `QDL.note_type e` will display the type of `e` during type checking. At run time, this method returns its argument. Note that in certain cases QDL may type check the same code repeatedly, in which case an expression's type could be printed multiple times.

* *Conditional guards and singletons.* If an `if` or `unless` guard has a singleton type, QDL will typecheck both branches but not include types from the unrealizable branch in the expression type. For example, `if true then 1 else 'two' end` has type `1`. QDL behaves similarly for `&&` and `||`. However, QDL does not implement this logic for `case`.

* *Case analysis by class.* If the guard of a `case` statement is a variable, and then `when` branches compare against classes, QDL refines the type of the guard to be those classes within the corresponding `when` branch. For example, in `case x when Integer ...(1)... when String ...(2)... end`, QDL will assume `x` is an `Integer` within `(1)` and a `String` within `(2)`.

* *Multiple Assignment and nil.* In Ruby, extra left-hand sides of multiple assignments are set to `nil`, e.g., `x, y = [1]` sets `x` to `1` and `y` to `nil`. However, QDL reports an error in this case; this may change in the future.

* *Block formal arguments.* Similarly, QDL reports an error if a block is called with the wrong number of arguments even though Ruby does not signal an error in this case.

* *Caching.* If `typecheck: :call` is specified on a method, Ruby will type check the method every time it is called. In the future, QDL will cache these checks.

* *Dependent Types.* QDL ignores refinements in checking code with dependent types. E.g., given an `Integer x {{ x > 0 }}`, QDL will simply treat `x` as an `Integer` and ignore the requirement that it be positive.

* *Unsupported Features.* There are several features of Ruby that are currently not handled by QDL. Here is a non-exhaustive list:
  * `super` is not supported.
  * `lambda` has special semantics for `return`; this is not supported. Stabby lambda is also not supported.
  * Only simple `for` iteration variables are supported.
  * Control flow for exceptions is not analyzed fully soundly; some things are not reported as possibly `nil` that could be.
  * Only simple usage of constants is handled.

## Assumptions

QDL's static type checker makes some assumptions that should hold unless your Ruby code is doing something highly unusual. QDL assumes:

* `Class#===` is not redefined
* `Proc#call` is not redefined
* `Object#class` is not redefined
* Methods that take blocks with externally visible effects do not store those blocks and then call them later

(More assumptions will be added here as they are added to QDL...)

# Type-Level Computations

QDL includes support for type-level computations: embedding Ruby code *within* a method's type signature. Using these type-level computations, we can write type signatures that can check more expressive properties, such as the correctness of column names and types in a database query. We have found that type-level computations significantly reduce the need for manually inserted type casts. Below we will cover the basics of using type-level computations. For a closer look, check out our [paper](https://www.cs.tufts.edu/~jfoster/papers/pldi19.pdf) on the same topic.

We use type-level computations only in type signatures for methods which themselves are *not* type checked. Thus, our primary focus is on applying them to library methods. We add a computation to a type by writing Ruby code, delimited by double backticks \`\`...\`\`, in place of a type within a method's signature. This Ruby code may refer to two special variables: `trec`, which names the QDL type of the receiver for a given method call, and `targs`, which names an array of QDL types of the arguments for a given method call. The code must itself evaluate to a type.

As an example, we will write a type-level computation for the `Integer#+` method. Normaly, this method would have the simple QDL type `type '(Integer) -> Integer'` (for the case that it takes another `Integer`). Using type level computations, we can write the following more precise type:

```ruby
type '(Integer) -> ``if trec.is_a?(QDL::Type::SingletonType) && targs[0].is_a?(QDL::Type::SingletonType) then QDL::Type::SingletonType.new(trec.val+targs[0].val) else QDL::Type::NominalType.new(Integer) end``'
```

Now, in place of a simple return type, we have written some Ruby code. This code checks if both the receiver (`trec`) and argument (`targs[0]`) have a singleton type. If so, in the first arm of the branch we compute a new singleton type containing the sum of the receiver and argument. Otherwise, we fall back on returning the nominal type `Integer`. With this signature, QDL can determine the expression `1+2` has the type `3`, rather than the less precise type `Integer`.

We also provide a way of binding variable names to argument types, to avoid using the variable `targs`. For example, for the type signature above, we can give the argument type the name `t`, which we then refer to in the type-level computation:

```ruby
type '(Integer) -> ``if trec.is_a?(QDL::Type::SingletonType) && t.is_a?(QDL::Type::SingletonType) then QDL::Type::SingletonType.new(trec.val+t.val) else QDL::Type::NominalType.new(Integer) end``'
```

We have written type-level computations for methods from the Integer, Float, Array, Hash, and String core libraries, which you can find  in the `/lib/types/core/` directory. We have also written them for a number of database query methods from both the [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord) and [Sequel](https://github.com/jeremyevans/sequel) DSLs. They can be found in `comp_types.rb` file in the `/lib/types/rails/active_record` and `/lib/types/sequel` directories, respectively. These type-level computations for the database query methods depend on QDL pre-processing the schema of the database before type checking any user code. QDL provides helper methods to process the database schema:

```ruby
QDL.load_sequel_schema(DATABASE) # `DATABASE` is the Sequel Database object

QDL.load_rails_schema # Automatically triggered if QDL is loaded in a Rails environment. If you want to use ActiveRecord without Rails, you need to call this method
```

Because type-level computations are used for methods which themselves are not type checked, we include an optional configuration for inserting dynamic checks that ensure that these methods return values of the type expected by their type-level computation. Additionally, because type-level computations can refer to mutable state, we include a second configuration for re-running type-level computations at runtime to ensure that they evaluate to the same value they did at type checking time. Both of these configurations are by default turned off. See the [Configuration](#configuration) section for information on turning them on.

# QDL Method Reference

The following methods are available in `QDL::Annotate`.

* `pre [klass], [meth], &blk, wrap: true, version: nil` - add `blk` as a precondition contract on `klass#meth`. If `klass` is omitted, applies to `self`. If `meth` is also omitted, applies to next defined method. If `wrap` is true, wrap the method to actually check the precondition. If it's false, don't wrap the method (this is probably useless). If a `version` string or array of strings is specified (in rubygems format), only apply when the current Ruby version matches.

* `post [klass], [meth], &blk, wrap: true, version: nil` - same as `pre`, but add a postcondition.

* `type [klass], [meth], typ, wrap: true, typecheck: nil, version: nil` - same as `pre`, but add a type specification. If `typecheck` is `nil`, does no static type checking. If it's `:call`, will type check the method each time it's called. If it's `:now`, will type check the method after it's defined. If it's some other `symbol`, will type check the method when `QDL.do_typecheck symbol` is called.

* `var_type [klass], var, typ` - indicate the `typ` is the type for `var`, which may be a `:@field` or `:local_variable`.

* `attr_accessor_type :name1, typ1, ...` calls `attr_accessor :name1, ...` and creates type annotations for the given field and its getters and setters.

* `attr_reader_type`, `attr_type`, and `attr_writer_type` - analogous to `attr_accessor_type`

* `qdl_alias [klass], new_name, old_name` tells QDL that method `new_name` of `klass` is an alias for method `old_name` (of the same class), and therefore they should have the same contracts and types. This method is only needed when adding contracts and types to method that have already been aliased; it's not needed if the method is aliased after the contract or type has been added. If the `klass` argument is omitted it's assumed to be `self`.

* `type_params [klass] [:param1, ...], :all, variance: nil, [&blk]` - indicates that `klass` should be treated as a generic type with parameters `:param1...`. The `:all` argument names a method of `klass` that iterates through a `klass` instance's contents. Alternatively, if a block is passed as an argument, that block is used as the iterator. The `variance` argument gives an array of variances of the parameters, `:+` for covariant, `:-` for contravaraiant, and `:~` for invariant. If `variance` is omitted, the parameters are assumed to be invariant.

The methods above can also be accessed as `qdl_method` after `extend QDL::QDLAnnotate`. They can also be accessed as `QDL.method`, but when doing so, however, the `klass` and `meth` arguments are not optional and must be specified. The `QDL` module also includes several other useful methods:

* `QDL.at(sym, &blk)` invokes `blk.call(sym)` when `QDL.do_typecheck(sym)` is called. Useful when type annotations need to be generated at some later time, e.g., because not all classes are loaded.

* `QDL.deinsantiate!(var)` - remove `var`'s instantiation.

* `QDL.do_typecheck(sym)` statically type checks all methods whose type annotations include argument `typecheck: sym`.

* `QDL.insantiate!(var, typ1, ...)` - `var` must have a generic type. Instantiates the type of `x` with type parameters `typ1`, ...

* `QDL.note_type e` - evaluates `e` and returns it at run time. During static type checking, prints out the type of `e`.

* `QDL.nowrap [klass]`, if called at the top-level of a class, causes QDL to behave as if `wrap: false` were passed to all `type`, `pre`, and `post` calls in `klass`. This is mostly used for the core and standard libraries, which have trustworthy behavior hence enforcing their types and contracts is not worth the overhead. If `klass` is omitted it's assumed to be `self`.

* `QDL.query` prints information about types; see below for details.

* `QDL.remove_type klass, meth` removes the type annotation for meth in klass. Fails if meth does not have a type annotation.

* `QDL.reset` resets all global state stored internally inside QDL back to their original settings. Note: this is really only for internal QDL testing, as it doesn't completely undo QDL's effect (e.g., wrapped methods will be broken by a reset).

* `QDL.type_alias '%name', typ` - indicates that if `%name` appears in a type annotations, it should be expanded to `typ`.

* `QDL.type_cast(e, typ, force: false)` - evaluate `e` and return it at run time. During dynamic contract checking, the returned object will have `typ` associated with it. If `force` is `false`, will also check that `e`'s run-time type is compatible with `typ`. If `force` is true then `typ` will be applied regaqdless of `e`'s type. During static type checking, the type checker will treat the object returned by `type_cast` has having type `typ`.



# Performance

QDL supports some tradeoffs between safety and performance. There are three main sources of overhead in using QDL:

* When a method is wrapped by QDL, invoking it is more expensive because it requires calling the wrapper which then calls the underlying method. This is the most significant run-time cost of using QDL, and it can be eliminated by adding `wrap: false` to an annotation. (But, this only makes sense for types, since those are the only annotations that can be statically checked.)

* When type checking is performed, QDL parses the program's source code and type checks method bodies. This source of overhead only happens once per method (unless `typecheck: :call` is used), so the overhead is probably not too bad (though we have not measured it).

* QDL adds an implementation of `method_added` and `singleton_method_added` to carry out some of its work, and those are called on every method addition. This source of overhead is again likely not too significant.

For uses of `pre` and `post`, there's not a lot of choice: those contracts are enforced at run-time and will incur the costs of wrapped methods. However, note that any methods that are not annotated with `pre` or `post` will not incur the cost of wrapping. (Similarly, methods not annotated with `type` never incur any wrapping cost.)

For uses of `type`, there are more choices, which can be split into two main use cases. First, suppose there's a method `m` that we want a type for but don't want to type check (for example, it may come from some external library). So suppose we read the documentation and give `m` type `(Integer) -> Integer`. We now have to decide whether to wrap `m`. If we don't wrap `m`, then we incur no overhead on calls to `m`, but we are trusting the type. If we do wrap `m`, then on every call to it QDL will check that we call it with an `Integer` and it actually returns an `Integer`. So if we're not completely sure of `m`'s type, it might be useful to wrap it and then run test cases against it to see if the type annotation is every violated. (For example, the QDL developers did this to test out many of the core library annotations in QDL.)

Second, suppose there's a method `m` that we do want to type check, and again `m` has type `(Integer) -> Integer`. Now QDL will use type checking to ensure that if `m` is given an `Integer` then it returns `Integer`. But now we again have to decide whether to wrap `m`. If we don't wrap `m`, then we get the most efficiency, since typechecking (assuming we do not do it at calls) will only happen once and calls will incur no overhead. On the other hand, it could be that some non-typechecked code calls `m` with something that's not an `Integer`, in which case `m` might do anything, including report a type error. (Notice the type checking of `m` assumed its input was an `Integer`, and it doesn't say anything about the case when its argument is not.) To protect against this case, we can wrap `m`. Then if a caller violates `m`'s type, we'll get an error in the caller code when it tries to call `m`.

(Side note: If typed methods are wrapped, then their type contracts are checked at run time for *all* callers, including ones that are were statically type checked and hence couldn't call methods at incorrect types. A future version of QDL will fix this, but it will require some significant changes to QDL's implementation strategy.)

# Queries

As discussed above, QDL includes a small script, `qdl_query`, to look up type information. (Currently it does not support other pre- and postconditions.) The script takes a single argument, which should be a string. Note that when using the shell script, you may need to use quotes depending on your shell. Currently several queries are supported:

* Instance methods can be looked up as `Class#method`.

```shell
$ qdl_query String#include?
String#include?: (String) -> TrueClass or FalseClass
```

* Singleton (class) methods can be looked up as `Class.method`.

```shell
$ qdl_query Pathname.glob
Pathname.glob: (String p1, ?String p2) -> Array<Pathname>
```

* All methods of a class can be listed by passing the class name `Class`.

```shell
$ qdl_query Array
&: (Array<u>) -> Array<t>
*: (String) -> String
... and a lot more
```

* Methods can also be search for by their type signature:

```shell
$ qdl_query "(Integer) -> Integer"      # print all methods of type (Integer) -> Integer
BigDecimal.limit: (Integer) -> Integer
Dir#pos=: (Integer) -> Integer
... and a lot more
```

The type signature uses the standard QDL syntax, with two extensions: `.` can be used as a wildcard to match any type, and `...` can be used to match any sequence of arguments.

```shell
$ qdl_query "(.) -> ."                 # methods that take one argument and return anything
$ qdl_query "(Integer, .) -> ."        # methods that take two arguments, the first of which is an Integer
$ qdl_query "(Integer, ...) -> ."      # methods whose first argument is an Integer
$ qdl_query "(..., Integer) -> ."      # methods whose last argument is an Integer
$ qdl_query "(..., Integer, ...) -> ." # methods that take an Integer somewhere
$ qdl_query "(Integer or .) -> ."      # methods that take a single argument that is a union containing an Integer
$ qdl_query "(.?) -> ."                # methods that take one, optional argument
```

Note that aside from `.` and `...`, the matching is exact. For example `(Integer) -> Integer` will not match a method of type `(Integer or String) -> Integer`.

# Configuration

To configure QDL, execute the following shortly after QDL is loaded:

```ruby
QDL.config { |config|
  # use config to configure QDL here
}
```

QDL supports the following configuration options:

* `config.nowrap` - `Array<Class>` containing all classes whose methods should not be wrapped.
* `config.gather_stats` - currently disabled.
* `config.report` - if true, then when the program exits, QDL will print out a list of methods that were statically type checked, and methods that were annotated to be statically type checked but weren't.
* `config.guess_types` - List of classes (of type `Array<Symbol>`). For every method added to a listed class *after* this configuration option is set, QDL will record the types of its arguments and returns at run-time. Then when the program exits, QDL will print out a skeleton for each class with types for the monitored methods based on what QDL recorded at run-time and based on what Ruby knows about the methods' signatures. This is probably not going to produce the correct method types, but it might be a good starting place.
* `config.type_defaults` - Hash containing default options for `type`. Initially `{ wrap: true, typecheck: false }`.
* `config.pre_defaults` - Hash containing default options for `pre`. Initially `{ wrap: true }`.
* `config.post_defaults` - same as `pre_defaults`, but for `post`.
* `config.use_comp_types` - when true, QDL makes use of types with type-level computations. When false, QDL ignores such types. By default set to true.
* `config.check_comp_types` - when true, QDL inserts dynamic checks which ensure that methods with type-level computations will return the expected type. False by default.
* `config.rerun_comp_types` - when true, QDL inserts dynamic checks which rerun type-level computations at method call sites, ensuring that they evaluate to the same type they did at type checking time.  False by default.


# Bibliography

Here are some research papers we have written exploring types, contracts, and Ruby.

* Milod Kazerounian, Sankha Narayan Guria, Niki Vazou, Jeffrey S. Foster, and David Van Horn.
[Type-Level Computations for Ruby Libraries](https://www.cs.tufts.edu/~jfoster/papers/pldi19.pdf).
In ACM SIGPLAN Conference on Programming Language Design and Implementation (PLDI), Phoenix, AZ, June 2019.

* Brianna M. Ren and Jeffrey S. Foster.
[Just-in-Time Static Type Checking for Dynamic Languages](http://www.cs.tufts.edu/~jfoster/papers/pldi16.pdf).
In ACM SIGPLAN Conference on Programming Language Design and Implementation (PLDI), Santa Barbara, CA, June 2016.

* T. Stephen Strickland, Brianna Ren, and Jeffrey S. Foster.
[Contracts for Domain-Specific Languages in Ruby](http://www.cs.tufts.edu/~jfoster/papers/dls12.pdf).
In Dynamic Languages Symposium (DLS), Portland, OR, October 2014.

* Brianna M. Ren, John Toman, T. Stephen Strickland, and Jeffrey S. Foster.
[The Ruby Type Checker](http://www.cs.tufts.edu/~jfoster/papers/oops13.pdf).
In Object-Oriented Program Languages and Systems (OOPS) Track at ACM Symposium on Applied Computing, pages 1565–1572, Coimbra, Portugal, March 2013.

* Jong-hoon (David) An, Avik Chaudhuri, Jeffrey S. Foster, and Michael Hicks.
[Dynamic Inference of Static Types for Ruby](http://www.cs.tufts.edu/~jfoster/papers/popl11.pdf).
In ACM SIGPLAN-SIGACT Symposium on Principles of Programming Languages (POPL), pages 459–472, Austin, TX, USA, January 2011.

* Jong-hoon (David) An.
[Dynamic Inference of Static Types for Ruby](http://www.cs.tufts.edu/~jfoster/papers/thesis-an.pdf).
MS thesis, University of Maryland, College Park, 2010.

* Michael Furr.
[Combining Static and Dynamic Typing in Ruby](https://www.cs.tufts.edu/~jfoster/papers/thesis-furr.pdf).
PhD thesis, University of Maryland, College Park, 2009.

* Michael Furr, Jong-hoon (David) An, Jeffrey S. Foster, and Michael Hicks.
[The Ruby Intermediate Langauge](http://www.cs.tufts.edu/~jfoster/papers/dls09-ril.pdf).
In Dynamic Languages Symposium (DLS), pages 89–98, Orlando, Florida, October 2009.

* Michael Furr, Jong-hoon (David) An, and Jeffrey S. Foster.
[Profile-Guided Static Typing for Dynamic Scripting Languages](http://www.cs.tufts.edu/~jfoster/papers/oopsla09.pdf).
In ACM SIGPLAN International Conference on Object-Oriented Programming, Systems, Languages and Applications (OOPSLA), pages 283–300, Orlando, Floria, October 2009. Best student paper award.

* Michael Furr, Jong-hoon (David) An, Jeffrey S. Foster, and Michael Hicks.
[Static Type Inference for Ruby](http://www.cs.tufts.edu/~jfoster/papers/oops09.pdf).
In Object-Oriented Program Languages and Systems (OOPS) Track at ACM Symposium on Applied Computing (SAC), pages 1859–1866, Honolulu, Hawaii, March 2009.

# Copyright

Copyright (c) 2014-2017, University of Maryland, College Park. All rights reserved.

# Contributing

Contributions are welcome! If you submit any pull requests, please
submit them against the `dev` branch. We keep the `master` branch so
it matches the latest gem version.

# Authors

* [Jeffrey S. Foster](http://www.cs.tufts.edu/~jfoster/)
* [Brianna M. Ren](https://www.cs.umd.edu/~bren/)
* [T. Stephen Strickland](https://www.cs.umd.edu/~sstrickl/)
* Alexander T. Yu
* Milod Kazerounian
* [Sankha Narayan Guria](https://sankhs.com/)

# Contributors

* [Joel Holdbrooks](https://github.com/noprompt)
* [Paul Tarjan](https://github.com/ptarjan)

# Discussion group

[QDL Users](https://groups.google.com/forum/#!forum/qdl-users)
