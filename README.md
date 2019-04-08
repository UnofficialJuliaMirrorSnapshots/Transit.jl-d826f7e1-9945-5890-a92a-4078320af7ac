# Transit.jl

Transit is a data format and a set of libraries for conveying values between applications written in different languages. This library provides support for marshalling Transit data to/from [Julia](http://julialang.org).

* [Rationale](http://blog.cognitect.com/blog/2014/7/22/transit)
* [Specification](http://github.com/cognitect/transit-format)

This implementation's major.minor version number corresponds to the version of the Transit specification it supports.

Currently only the JSON formats are implemented.
MessagePack is **not** implemented yet. 

_NOTE: Transit is a work in progress and may evolve based on feedback. As a result, while Transit is a great option for transferring data between applications, it should not yet be used for storing data durably over time. This recommendation will change when the specification is complete._

## Installation

Transit is available in Julia's METADATA.jl package repository:

```julia
Pkg.add("Transit")
```

## Usage

To use Transit in a project, import it:

```julia
import Transit
```

Transit will read or write data using any IO interface in Julia that is supported
by the JSON package. To write:

```julia
Transit.write(STDOUT, [123, "hello world", :value, 0, nothing])
# [123,"hello world","~:value",0,null]
```

To read:

```julia
iobuf = IOBuffer("[123, \"hello world\", \"~:value\",0,null]")
Transit.parse(iobuf)

# 5-element Array{Any,1}:
#   123             
#   "hello world"
#   :value       
#   0             
#   nothing  
```

## Default Type Mapping

_NOTE: The type mapping may change in the short term for Transit.jl if any types proves to be a mismatch with typical Julia expectations._


| Semantic Type | write accepts | read produces |
|:--------------|:--------------|:--------------|
| null| anything of type Void | nothing |
| string| string | string |
| boolean | Bool | Bool |
| integer, signed 64 bit| any signed or unsiged int type | Int64 |
| floating pt decimal| Float32 or Float64 | Float64 |
| bytes| Array{Int8} | Array{Int8} |
| keyword | Symbol | Symbol |
| symbol | Transit.TSymbol | Transit.TSymbol
| arbitrary precision decimal| Decimals.Decimal, BigFloat | Decimals.Decimal|
| arbitrary precision integer| BigInt | BigInt |
| point in time | DateTime | DateTime |
| point in time RFC 33339 | Date | Date |
| uuid | Base.Random.UUID| Base.Random.UUID|
| uri | Transit.TURI | Transit.TURI |
| char | Char | Char |
| special numbers | Inf, Nan| Inf, Nan
| array | arrays | Any[] |
| map | Dict | Dict{Any,Any} | 
| set |  Transit.TSet, Set | Transit.TSet |
| list | DataStructures.Cons | DataStructures.Cons |
| map w/ composite keys |  Dict{Array,Any} |  Dict{Array,Any} |
| link | Transit.TLink | Transit.TLink |


## Copyright and License
Copyright © 2016 Russ Olsen, Ben Kamphaus

This library is a Julia port of the Java and Ruby versions created and maintained by Cognitect, therefore

Copyright © 2014 Cognitect

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

This README file is based on the README from transit-csharp, therefore:

Copyright © 2014 NForza.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
