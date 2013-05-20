# NAME

Async::When - Perl Port of when.js

# SYNOPSIS

    use Async::When;

# DESCRIPTION

Async::When is Perl port of Javascript Library when.js.
The API is kept as close to the original as possible.

This is currently a minimal implementation.

# INTERFACES

## Funcional Interface

### When(@values or $promise)

Returns a promise. If the argument is already a promise, it is returned. Otherwise,
a new promise is created and immediately resolved with the provided value.

## Class Interfaces

### Async::When::defer

Create a deferred object, equivalent to `Async::When::Deferred-`new>.
The deferred can be split in its resolver and promise parts for better encapsulation.

### Async::When::resolve(@values)

Create a deferred and immediately resolves it with `@values`, then returns the promise.

### Async::When::reject(@values)

Create a deferred and immediately rejects it with `@values`, then returns the promise.

### Async::When::all(@promises)

Takes promises or deferreds and returns promise that will either reject when the
first promise rejects, or resolve when all promises have resolved.

# SEE ALSO

[https://github.com/cujojs/when](https://github.com/cujojs/when)

[https://github.com/cjohansen/when-rb](https://github.com/cjohansen/when-rb)

# LICENSE

Copyright (C) Syohei YOSHIDA.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Syohei YOSHIDA <syohex@gmail.com>
