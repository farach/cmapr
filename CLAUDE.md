# NA

\# Claude Instructions — CMapr R package \# Modern R Development Guide
\## Core Principles

1\. \*\*Use modern tidyverse patterns\*\* - Prioritize dplyr 1.1+
features, native pipe, and current APIs

2\. \*\*Profile before optimizing\*\* - Use profvis and bench to
identify real bottlenecks

3\. \*\*Write readable code first\*\* - Optimize only when necessary and
after profiling

4\. \*\*Follow tidyverse style guide\*\* - Consistent naming, spacing,
and structure

\## Modern Tidyverse Patterns \### Pipe Usage (`|>` not `%>%`) -
\*\*Always use native pipe `|>` instead of magrittr `%>%`\*\* - R 4.3+
provides all needed features

``` r
\# Good - Modern native pipe

data |> 

&nbsp; filter(year >= 2020) |>

&nbsp; summarise(mean\_value = mean(value))



\# Avoid - Legacy magrittr pipe  

data %>% 

&nbsp; filter(year >= 2020) %>%

&nbsp; summarise(mean\_value = mean(value))
```

\### Join Syntax (dplyr 1.1+)

\- \*\*Use `join\_by()` instead of character vectors for joins\*\*

\- \*\*Support for inequality, rolling, and overlap joins\*\*

``` r
\# Good - Modern join syntax

transactions |> 

&nbsp; inner\_join(companies, by = join\_by(company == id))



\# Good - Inequality joins

transactions |>

&nbsp; inner\_join(companies, join\_by(company == id, year >= since))



\# Good - Rolling joins (closest match)

transactions |>

&nbsp; inner\_join(companies, join\_by(company == id, closest(year >= since)))



\# Avoid - Old character vector syntax

transactions |> 

&nbsp; inner\_join(companies, by = c("company" = "id"))
```

\### Multiple Match Handling

\- \*\*Use `multiple` and `unmatched` arguments for quality control\*\*

``` r
\# Expect 1:1 matches, error on multiple

inner\_join(x, y, by = join\_by(id), multiple = "error")



\# Allow multiple matches explicitly  

inner\_join(x, y, by = join\_by(id), multiple = "all")



\# Ensure all rows match

inner\_join(x, y, by = join\_by(id), unmatched = "error")
```

\### Data Masking and Tidy Selection

\- \*\*Understand the difference between data masking and tidy
selection\*\*

\- \*\*Use `{{}}` (embrace) for function arguments\*\*

\- \*\*Use `.data\[\[]]` for character vectors\*\*

``` r
\# Data masking functions: arrange(), filter(), mutate(), summarise()

\# Tidy selection functions: select(), relocate(), across()



\# Function arguments - embrace with {{}}

my\_summary <- function(data, group\_var, summary\_var) {

&nbsp; data |>

&nbsp;   group\_by({{ group\_var }}) |>

&nbsp;   summarise(mean\_val = mean({{ summary\_var }}))

}



\# Character vectors - use .data\[\[]]

for (var in names(mtcars)) {

&nbsp; mtcars |> count(.data\[\[var]]) |> print()

}



\# Multiple columns - use across()

data |> 

&nbsp; summarise(across({{ summary\_vars }}, ~ mean(.x, na.rm = TRUE)))
```

\### Modern Grouping and Column Operations

\- \*\*Use `.by` for per-operation grouping (dplyr 1.1+)\*\*

\- \*\*Use `pick()` for column selection inside data-masking
functions\*\*

\- \*\*Use `across()` for applying functions to multiple columns\*\*

\- \*\*Use `reframe()` for multi-row summaries\*\*

``` r
\# Good - Per-operation grouping (always returns ungrouped)

data |>

&nbsp; summarise(mean\_value = mean(value), .by = category)



\# Good - Multiple grouping variables

data |>

&nbsp; summarise(total = sum(revenue), .by = c(company, year))



\# Good - pick() for column selection

data |>

&nbsp; summarise(

&nbsp;   n\_x\_cols = ncol(pick(starts\_with("x"))),

&nbsp;   n\_y\_cols = ncol(pick(starts\_with("y")))

&nbsp; )



\# Good - across() for applying functions

data |>

&nbsp; summarise(across(where(is.numeric), mean, .names = "mean\_{.col}"), .by = group)



\# Good - reframe() for multi-row results

data |>

&nbsp; reframe(quantiles = quantile(x, c(0.25, 0.5, 0.75)), .by = group)



\# Avoid - Old persistent grouping pattern

data |>

&nbsp; group\_by(category) |>

&nbsp; summarise(mean\_value = mean(value)) |>

&nbsp; ungroup()
```

\## Modern rlang Patterns for Data-Masking

\### Core Concepts

\*\*Data-masking\*\* allows R expressions to refer to data frame columns
as if they were variables in the environment. rlang provides the
metaprogramming framework that powers tidyverse data-masking.

\#### Key rlang Tools

\- \*\*Embracing `{{}}`\*\* - Forward function arguments to data-masking
functions

\- \*\*Injection `!!`\*\* - Inject single expressions or values

\- \*\*Splicing `!!!`\*\* - Inject multiple arguments from a list

\- \*\*Dynamic dots\*\* - Programmable `...` with injection support

\- \*\*Pronouns `.data`/`.env`\*\* - Explicit disambiguation between
data and environment variables

\### Function Argument Patterns

\#### Forwarding with `{{}}`

\*\*Use `{{}}` to forward function arguments to data-masking
functions:\*\*

``` r
\# Single argument forwarding

my\_summarise <- function(data, var) {

&nbsp; data |> dplyr::summarise(mean = mean({{ var }}))

}



\# Works with any data-masking expression

mtcars |> my\_summarise(cyl)

mtcars |> my\_summarise(cyl \* am)

mtcars |> my\_summarise(.data$cyl)  # pronoun syntax supported
```

\#### Forwarding `...` (No Special Syntax Needed)

``` r
\# Simple dots forwarding

my\_group\_by <- function(.data, ...) {

&nbsp; .data |> dplyr::group\_by(...)

}



\# Works with tidy selections too

my\_select <- function(.data, ...) {

&nbsp; .data |> dplyr::select(...)

}



\# For single-argument tidy selections, wrap in c()

my\_pivot\_longer <- function(.data, ...) {

&nbsp; .data |> tidyr::pivot\_longer(c(...))

}
```

\#### Names Patterns with `.data`

\*\*Use `.data` pronoun for programmatic column access:\*\*

``` r
\# Single column by name

my\_mean <- function(data, var) {

&nbsp; data |> dplyr::summarise(mean = mean(.data\[\[var]]))

}



\# Usage - completely insulated from data-masking

mtcars |> my\_mean("cyl")  # No ambiguity, works like regular function



\# Multiple columns with all\_of()

my\_select\_vars <- function(data, vars) {

&nbsp; data |> dplyr::select(all\_of(vars))

}



mtcars |> my\_select\_vars(c("cyl", "am"))
```

\### Injection Operators

\#### When to Use Each Operator

Operator \| Use Case \| Example \|

\|———-\|———-\|———\|

`{{ }}` \| Forward function arguments \|
`summarise(mean = mean({{ var }}))` \|

`!!` \| Inject single expression/value \|
`summarise(mean = mean(!!sym(var)))` \|

`!!!` \| Inject multiple arguments \| `group\_by(!!!syms(vars))` \|

`.data\[\[]]` \| Access columns by name \| `mean(.data\[\[var]])` \|

\#### Advanced Injection with `!!`

``` r
\# Create symbols from strings

var <- "cyl"

mtcars |> dplyr::summarise(mean = mean(!!sym(var)))



\# Inject values to avoid name collisions

df <- data.frame(x = 1:3)

x <- 100

df |> dplyr::mutate(scaled = x / !!x)  # Uses both data and env x



\# Use data\_sym() for tidyeval contexts (more robust)

mtcars |> dplyr::summarise(mean = mean(!!data\_sym(var)))
```

\#### Splicing with `!!!`

``` r
\# Multiple symbols from character vector

vars <- c("cyl", "am")

mtcars |> dplyr::group\_by(!!!syms(vars))



\# Or use data\_syms() for tidy contexts

mtcars |> dplyr::group\_by(!!!data\_syms(vars))



\# Splice lists of arguments

args <- list(na.rm = TRUE, trim = 0.1)

mtcars |> dplyr::summarise(mean = mean(cyl, !!!args))
```

\### Dynamic Dots Patterns

\#### Using `list2()` for Dynamic Dots Support

``` r
my\_function <- function(...) {

&nbsp; # Collect with list2() instead of list() for dynamic features

&nbsp; dots <- list2(...)

&nbsp; # Process dots...

}



\# Enables these features:

my\_function(a = 1, b = 2)           # Normal usage

my\_function(!!!list(a = 1, b = 2))  # Splice a list

my\_function("{name}" := value)      # Name injection

my\_function(a = 1, )               # Trailing commas OK
```

\#### Name Injection with Glue Syntax

``` r
\# Basic name injection

name <- "result"

list2("{name}" := 1)  # Creates list(result = 1)



\# In function arguments with {{

my\_mean <- function(data, var) {

&nbsp; data |> dplyr::summarise("mean\_{{ var }}" := mean({{ var }}))

}



mtcars |> my\_mean(cyl)        # Creates column "mean\_cyl"

mtcars |> my\_mean(cyl \* am)   # Creates column "mean\_cyl \* am"



\# Allow custom names with englue()

my\_mean <- function(data, var, name = englue("mean\_{{ var }}")) {

&nbsp; data |> dplyr::summarise("{name}" := mean({{ var }}))

}



\# User can override default

mtcars |> my\_mean(cyl, name = "cylinder\_mean")
```

\### Pronouns for Disambiguation

\#### `.data` and `.env` Best Practices

``` r
\# Explicit disambiguation prevents masking issues

cyl <- 1000  # Environment variable



mtcars |> dplyr::summarise(

&nbsp; data\_cyl = mean(.data$cyl),    # Data frame column

&nbsp; env\_cyl = mean(.env$cyl),      # Environment variable

&nbsp; ambiguous = mean(cyl)          # Could be either (usually data wins)

)



\# Use in loops and programmatic contexts

vars <- c("cyl", "am")

for (var in vars) {

&nbsp; result <- mtcars |> dplyr::summarise(mean = mean(.data\[\[var]]))

&nbsp; print(result)

}
```

\### Programming Patterns

\#### Bridge Patterns

\*\*Converting between data-masking and tidy selection behaviors:\*\*

``` r
\# across() as selection-to-data-mask bridge

my\_group\_by <- function(data, vars) {

&nbsp; data |> dplyr::group\_by(across({{ vars }}))

}



\# Works with tidy selection

mtcars |> my\_group\_by(starts\_with("c"))



\# across(all\_of()) as names-to-data-mask bridge  

my\_group\_by <- function(data, vars) {

&nbsp; data |> dplyr::group\_by(across(all\_of(vars)))

}



mtcars |> my\_group\_by(c("cyl", "am"))
```

\#### Transformation Patterns

``` r
\# Transform single arguments by wrapping

my\_mean <- function(data, var) {

&nbsp; data |> dplyr::summarise(mean = mean({{ var }}, na.rm = TRUE))

}



\# Transform dots with across()

my\_means <- function(data, ...) {

&nbsp; data |> dplyr::summarise(across(c(...), ~ mean(.x, na.rm = TRUE)))

}



\# Manual transformation (advanced)

my\_means\_manual <- function(.data, ...) {

&nbsp; vars <- enquos(..., .named = TRUE)

&nbsp; vars <- purrr::map(vars, ~ expr(mean(!!.x, na.rm = TRUE)))

&nbsp; .data |> dplyr::summarise(!!!vars)

}
```

\### Error-Prone Patterns to Avoid

\#### Don’t Use These Deprecated/Dangerous Patterns

``` r
\# Avoid - String parsing and eval (security risk)

var <- "cyl" 

code <- paste("mean(", var, ")")

eval(parse(text = code))  # Dangerous!



\# Good - Symbol creation and injection

!!sym(var)  # Safe symbol injection



\# Avoid - get() in data mask (name collisions)

with(mtcars, mean(get(var)))  # Collision-prone



\# Good - Explicit injection or .data

with(mtcars, mean(!!sym(var)))  # Safe

\# or

mtcars |> summarise(mean(.data\[\[var]]))  # Even safer
```

\#### Common Mistakes

``` r
\# Don't use {{ }} on non-arguments

my\_func <- function(x) {

&nbsp; x <- force(x)  # x is now a value, not an argument

&nbsp; quo(mean({{ x }}))  # Wrong! Captures value, not expression

}



\# Don't mix injection styles unnecessarily

\# Pick one approach and stick with it:

\# Either: embrace pattern

my\_func <- function(data, var) data |> summarise(mean = mean({{ var }}))

\# Or: defuse-and-inject pattern  

my\_func <- function(data, var) {

&nbsp; var <- enquo(var)

&nbsp; data |> summarise(mean = mean(!!var))

}
```

\### Package Development with rlang

\#### Import Strategy

``` r
\# In DESCRIPTION:

Imports: rlang



\# In NAMESPACE, import specific functions:

importFrom(rlang, enquo, enquos, expr, !!!, :=)



\# Or import key functions:

\#' @importFrom rlang := enquo enquos
```

\#### Documentation Tags

``` r
\#' @param var <\[`data-masked`]\[dplyr::dplyr\_data\_masking]> Column to summarize

\#' @param ... <\[`dynamic-dots`]\[rlang::dyn-dots]> Additional grouping variables  

\#' @param cols <\[`tidy-select`]\[dplyr::dplyr\_tidy\_select]> Columns to select
```

\#### Testing rlang Functions

``` r
\# Test data-masking behavior

test\_that("function supports data masking", {

&nbsp; result <- my\_function(mtcars, cyl)

&nbsp; expect\_equal(names(result), "mean\_cyl")

&nbsp; 

&nbsp; # Test with expressions

&nbsp; result2 <- my\_function(mtcars, cyl \* 2)

&nbsp; expect\_true("mean\_cyl \* 2" %in% names(result2))

})



\# Test injection behavior

test\_that("function supports injection", {

&nbsp; var <- "cyl"

&nbsp; result <- my\_function(mtcars, !!sym(var))

&nbsp; expect\_true(nrow(result) > 0)

})
```

This modern rlang approach enables clean, safe metaprogramming while
maintaining the intuitive data-masking experience users expect from
tidyverse functions.

\## Performance Best Practices

\## Performance Tool Selection Guide

\### When to Use Each Performance Tool

\#### Profiling Tools Decision Matrix

Tool \| Use When \| Don’t Use When \| What It Shows \|

\|——\|———-\|—————-\|—————\|

\*\*`profvis`\*\* \| Complex code, unknown bottlenecks \| Simple
functions, known issues \| Time per line, call stack \|

\*\*`bench::mark()`\*\* \| Comparing alternatives \| Single approach \|
Relative performance, memory \|

\*\*[`system.time()`](https://rdrr.io/r/base/system.time.html)\*\* \|
Quick checks \| Detailed analysis \| Total runtime only \|

\*\*[`Rprof()`](https://rdrr.io/r/utils/Rprof.html)\*\* \| Base R only
environments \| When profvis available \| Raw profiling data \|

\#### Step-by-Step Performance Workflow

``` r
\# 1. Profile first - find the actual bottlenecks

library(profvis)

profvis({

&nbsp; # Your slow code here

})



\# 2. Focus on the slowest parts (80/20 rule)

\# Don't optimize until you know where time is spent



\# 3. Benchmark alternatives for hot spots

library(bench)

bench::mark(

&nbsp; current = current\_approach(data),

&nbsp; vectorized = vectorized\_approach(data),

&nbsp; parallel = map(data, in\_parallel(func))

)



\# 4. Consider tool trade-offs based on bottleneck type
```

\#### When Each Tool Helps vs Hurts

\*\*Parallel Processing (`in\_parallel()`)\*\*

``` r
\# Helps when:

✓ CPU-intensive computations

✓ Embarassingly parallel problems  

✓ Large datasets with independent operations

✓ I/O bound operations (file reading, API calls)



\# Hurts when:

✗ Simple, fast operations (overhead > benefit)

✗ Memory-intensive operations (may cause thrashing)

✗ Operations requiring shared state

✗ Small datasets



\# Example decision point:

expensive\_func <- function(x) Sys.sleep(0.1) # 100ms per call

fast\_func <- function(x) x^2                 # microseconds per call



\# Good for parallel

map(1:100, in\_parallel(expensive\_func))  # ~10s -> ~2.5s on 4 cores



\# Bad for parallel (overhead > benefit)  

map(1:100, in\_parallel(fast\_func))       # 100μs -> 50ms (500x slower!)
```

\*\*vctrs Backend Tools\*\*

``` r
\# Use vctrs when:

✓ Type safety matters more than raw speed

✓ Building reusable package functions

✓ Complex coercion/combination logic

✓ Consistent behavior across edge cases



\# Avoid vctrs when:

✗ One-off scripts where speed matters most

✗ Simple operations where base R is sufficient  

✗ Memory is extremely constrained



\# Decision point:

simple\_combine <- function(x, y) c(x, y)           # Fast, simple

robust\_combine <- function(x, y) vec\_c(x, y)      # Safer, slight overhead



\# Use simple for hot loops, robust for package APIs
```

\*\*Data Backend Selection\*\*

``` r
\# Use data.table when:

✓ Very large datasets (>1GB)

✓ Complex grouping operations

✓ Reference semantics desired

✓ Maximum performance critical



\# Use dplyr when:

✓ Readability and maintainability priority

✓ Complex joins and window functions

✓ Team familiarity with tidyverse

✓ Moderate sized data (<100MB)



\# Use base R when:

✓ No dependencies allowed

✓ Simple operations

✓ Teaching/learning contexts
```

\### Profiling Best Practices

``` r
\# 1. Profile realistic data sizes

profvis({

&nbsp; # Use actual data size, not toy examples

&nbsp; real\_data |> your\_analysis()

})



\# 2. Profile multiple runs for stability

bench::mark(

&nbsp; your\_function(data),

&nbsp; min\_iterations = 10,  # Multiple runs

&nbsp; max\_iterations = 100

)



\# 3. Check memory usage too

bench::mark(

&nbsp; approach1 = method1(data), 

&nbsp; approach2 = method2(data),

&nbsp; check = FALSE,  # If outputs differ slightly

&nbsp; filter\_gc = FALSE  # Include GC time

)



\# 4. Profile with realistic usage patterns

\# Not just isolated function calls
```

\### Performance Anti-Patterns to Avoid

``` r
\# Don't optimize without measuring

\# ✗ "This looks slow" -> immediately rewrite

\# ✓ Profile first, optimize bottlenecks



\# Don't over-engineer for performance  

\# ✗ Complex optimizations for 1% gains

\# ✓ Focus on algorithmic improvements



\# Don't assume - measure

\# ✗ "for loops are always slow in R"

\# ✓ Benchmark your specific use case



\# Don't ignore readability costs

\# ✗ Unreadable code for minor speedups

\# ✓ Readable code with targeted optimizations
```

\### Backend Tools for Performance

\- \*\*Consider lower-level tools when speed is critical\*\*

\- \*\*Use vctrs, rlang backends when appropriate\*\*

\- \*\*Profile to identify true bottlenecks\*\*

``` r
\# For packages - consider backend tools

\# vctrs for type-stable vector operations

\# rlang for metaprogramming

\# data.table for large data operations
```

\## When to Use vctrs

\### Core Benefits

\- \*\*Type stability\*\* - Predictable output types regardless of input
values

\- \*\*Size stability\*\* - Predictable output sizes from input sizes

\- \*\*Consistent coercion rules\*\* - Single set of rules applied
everywhere

\- \*\*Robust class design\*\* - Proper S3 vector infrastructure

\### Use vctrs when:

\#### Building Custom Vector Classes

``` r
\# Good - vctrs-based vector class

new\_percent <- function(x = double()) {

&nbsp; vec\_assert(x, double())

&nbsp; new\_vctr(x, class = "pkg\_percent")

}



\# Automatic data frame compatibility, subsetting, etc.
```

\#### Type-Stable Functions in Packages

``` r
\# Good - Guaranteed output type

my\_function <- function(x, y) {

&nbsp; # Always returns double, regardless of input values

&nbsp; vec\_cast(result, double())

}



\# Avoid - Type depends on data

sapply(x, function(i) if(condition) 1L else 1.0)
```

\#### Consistent Coercion/Casting

``` r
\# Good - Explicit casting with clear rules

vec\_cast(x, double())  # Clear intent, predictable behavior



\# Good - Common type finding

vec\_ptype\_common(x, y, z)  # Finds richest compatible type



\# Avoid - Base R inconsistencies  

c(factor("a"), "b")  # Unpredictable behavior
```

\#### Size/Length Stability

``` r
\# Good - Predictable sizing

vec\_c(x, y)  # size = vec\_size(x) + vec\_size(y)

vec\_rbind(df1, df2)  # size = sum of input sizes



\# Avoid - Unpredictable sizing

c(env\_object, function\_object)  # Unpredictable length
```

\### vctrs vs Base R Decision Matrix

Use Case \| Base R \| vctrs \| When to Choose vctrs \|

\|———-\|——–\|——-\|———————\|

Simple combining \| [`c()`](https://rdrr.io/r/base/c.html) \| `vec\_c()`
\| Need type stability, consistent rules \|

Custom classes \| S3 manually \| `new\_vctr()` \| Want data frame
compatibility, subsetting \|

Type conversion \| `as.\*()` \| `vec\_cast()` \| Need explicit, safe
casting \|

Finding common type \| Not available \| `vec\_ptype\_common()` \|
Combining heterogeneous inputs \|

Size operations \| [`length()`](https://rdrr.io/r/base/length.html) \|
`vec\_size()` \| Working with non-vector objects \|

\### Implementation Patterns

\#### Basic Vector Class

``` r
\# Constructor (low-level)

new\_percent <- function(x = double()) {

&nbsp; vec\_assert(x, double())

&nbsp; new\_vctr(x, class = "pkg\_percent")

}



\# Helper (user-facing)

percent <- function(x = double()) {

&nbsp; x <- vec\_cast(x, double())

&nbsp; new\_percent(x)

}



\# Format method

format.pkg\_percent <- function(x, ...) {

&nbsp; paste0(vec\_data(x) \* 100, "%")

}
```

\#### Coercion Methods

``` r
\# Self-coercion

vec\_ptype2.pkg\_percent.pkg\_percent <- function(x, y, ...) {

&nbsp; new\_percent()

}



\# With double

vec\_ptype2.pkg\_percent.double <- function(x, y, ...) double()

vec\_ptype2.double.pkg\_percent <- function(x, y, ...) double()



\# Casting

vec\_cast.pkg\_percent.double <- function(x, to, ...) {

&nbsp; new\_percent(x)

}

vec\_cast.double.pkg\_percent <- function(x, to, ...) {

&nbsp; vec\_data(x)

}
```

\### Performance Considerations

\#### When vctrs Adds Overhead

\- \*\*Simple operations\*\* - `vec\_c(1, 2)` vs `c(1, 2)` for basic
atomic vectors

\- \*\*One-off scripts\*\* - Type safety less critical than speed

\- \*\*Small vectors\*\* - Overhead may outweigh benefits

\#### When vctrs Improves Performance

\- \*\*Package functions\*\* - Type stability prevents expensive
re-computation

\- \*\*Complex classes\*\* - Consistent behavior reduces debugging

\- \*\*Data frame operations\*\* - Robust column type handling

\- \*\*Repeated operations\*\* - Predictable types enable optimization

\### Package Development Guidelines

\#### Exports and Dependencies

``` r
\# DESCRIPTION - Import specific functions

Imports: vctrs



\# NAMESPACE - Import what you need

importFrom(vctrs, vec\_assert, new\_vctr, vec\_cast, vec\_ptype\_common)



\# Or if using extensively

import(vctrs)
```

\#### Testing vctrs Classes

``` r
\# Test type stability

test\_that("my\_function is type stable", {

&nbsp; expect\_equal(vec\_ptype(my\_function(1:3)), vec\_ptype(double()))

&nbsp; expect\_equal(vec\_ptype(my\_function(integer())), vec\_ptype(double()))

})



\# Test coercion

test\_that("coercion works", {

&nbsp; expect\_equal(vec\_ptype\_common(new\_percent(), 1.0), double())

&nbsp; expect\_error(vec\_ptype\_common(new\_percent(), "a"))

})
```

\### Don’t Use vctrs When:

\- \*\*Simple one-off analyses\*\* - Base R is sufficient

\- \*\*No custom classes needed\*\* - Standard types work fine

\- \*\*Performance critical + simple operations\*\* - Base R may be
faster

\- \*\*External API constraints\*\* - Must return base R types

The key insight: \*\*vctrs is most valuable in package development where
type safety, consistency, and extensibility matter more than raw speed
for simple operations.\*\*

\### Modern purrr Patterns

\- \*\*Use `map() |> list\_rbind()`\*\* instead of superseded
`map\_dfr()`

\- \*\*Use `walk()` for side effects\*\* (file writing, plotting)

\- \*\*Use `in\_parallel()` for scaling\*\* across cores

``` r
\# Modern data frame row binding (purrr 1.0+)

models <- data\_splits |> 

&nbsp; map(\\(split) train\_model(split)) |>

&nbsp; list\_rbind()  # Replaces map\_dfr()



\# Column binding  

summaries <- data\_list |> 

&nbsp; map(\\(df) get\_summary\_stats(df)) |>

&nbsp; list\_cbind()  # Replaces map\_dfc()



\# Side effects with walk()

plots <- walk2(data\_list, plot\_names, \\(df, name) {

&nbsp; p <- ggplot(df, aes(x, y)) + geom\_point()

&nbsp; ggsave(name, p)

})



\# Parallel processing (purrr 1.1.0+)

library(mirai)

daemons(4)

results <- large\_datasets |> 

&nbsp; map(in\_parallel(expensive\_computation))

daemons(0)
```

\### String Manipulation with stringr

\- \*\*Use stringr over base R string functions\*\*

\- \*\*Consistent `str\_` prefix and string-first argument order\*\*

\- \*\*Pipe-friendly and vectorized by design\*\*

``` r
\# Good - stringr (consistent, pipe-friendly)

text |>

&nbsp; str\_to\_lower() |>

&nbsp; str\_trim() |>

&nbsp; str\_replace\_all("pattern", "replacement") |>

&nbsp; str\_extract("\\\\d+")



\# Common patterns

str\_detect(text, "pattern")     # vs grepl("pattern", text)

str\_extract(text, "pattern")    # vs complex regmatches()

str\_replace\_all(text, "a", "b") # vs gsub("a", "b", text)

str\_split(text, ",")            # vs strsplit(text, ",")

str\_length(text)                # vs nchar(text)

str\_sub(text, 1, 5)             # vs substr(text, 1, 5)



\# String combination and formatting

str\_c("a", "b", "c")            # vs paste0()

str\_glue("Hello {name}!")       # templating

str\_pad(text, 10, "left")       # padding

str\_wrap(text, width = 80)      # text wrapping



\# Case conversion  

str\_to\_lower(text)              # vs tolower()

str\_to\_upper(text)              # vs toupper()

str\_to\_title(text)              # vs tools::toTitleCase()



\# Pattern helpers for clarity

str\_detect(text, fixed("$"))    # literal match

str\_detect(text, regex("\\\\d+")) # explicit regex

str\_detect(text, coll("é", locale = "fr")) # collation



\# Avoid - inconsistent base R functions

grepl("pattern", text)          # argument order varies

regmatches(text, regexpr(...))  # complex extraction

gsub("a", "b", text)           # different arg order
```

\### Vectorization and Performance

``` r
\# Good - vectorized operations

result <- x + y



\# Good - Type-stable purrr functions

map\_dbl(data, mean)    # always returns double

map\_chr(data, class)   # always returns character



\# Avoid - Type-unstable base functions

sapply(data, mean)     # might return list or vector



\# Avoid - explicit loops for simple operations

result <- numeric(length(x))

for(i in seq\_along(x)) {

&nbsp; result\[i] <- x\[i] + y\[i]

}
```

\## Function Writing Best Practices

\### Structure and Style

``` r
\# Good function structure

rescale01 <- function(x) {

&nbsp; rng <- range(x, na.rm = TRUE, finite = TRUE)

&nbsp; (x - rng\[1]) / (rng\[2] - rng\[1])

}



\# Use type-stable outputs

map\_dbl()   # returns numeric vector

map\_chr()   # returns character vector  

map\_lgl()   # returns logical vector
```

\### Naming and Arguments

``` r
\# Good naming: snake\_case for variables/functions

calculate\_mean\_score <- function(data, score\_col) {

&nbsp; # Function body

}



\# Prefix non-standard arguments with .

my\_function <- function(.data, ...) {

&nbsp; # Reduces argument conflicts

}
```

\## Style Guide Essentials

\### Object Names

\- \*\*Use snake_case for all names\*\*

\- \*\*Variable names = nouns, function names = verbs\*\*

\- \*\*Avoid dots except for S3 methods\*\*

``` r
\# Good

day\_one

calculate\_mean  

user\_data



\# Avoid

DayOne

calculate.mean

userData
```

\### Spacing and Layout

``` r
\# Good spacing

x\[, 1]

mean(x, na.rm = TRUE)

if (condition) {

&nbsp; action()

}



\# Pipe formatting

data |>

&nbsp; filter(year >= 2020) |>

&nbsp; group\_by(category) |>

&nbsp; summarise(

&nbsp;   mean\_value = mean(value),

&nbsp;   count = n()

&nbsp; )
```

\## Common Anti-Patterns to Avoid

\### Legacy Patterns

``` r
\# Avoid - Old pipe

data %>% function()



\# Avoid - Old join syntax  

inner\_join(x, y, by = c("a" = "b"))



\# Avoid - Implicit type conversion

sapply()  # Use map\_\*() instead



\# Avoid - String manipulation in data masking

mutate(data, !!paste0("new\_", var) := value)  

\# Use across() or other approaches instead
```

\### Performance Anti-Patterns

``` r
\# Avoid - Growing objects in loops

result <- c()

for(i in 1:n) {

&nbsp; result <- c(result, compute(i))  # Slow!

}



\# Good - Pre-allocate

result <- vector("list", n)

for(i in 1:n) {

&nbsp; result\[\[i]] <- compute(i)

}



\# Better - Use purrr

result <- map(1:n, compute)
```

\## Object-Oriented Programming

\### S7: Modern OOP for New Projects

\- \*\*S7 combines S3 simplicity with S4 structure\*\*

\- \*\*Formal class definitions with automatic validation\*\*

\- \*\*Compatible with existing S3 code\*\*

``` r
\# S7 class definition

Range <- new\_class("Range",

&nbsp; properties = list(

&nbsp;   start = class\_double,

&nbsp;   end = class\_double

&nbsp; ),

&nbsp; validator = function(self) {

&nbsp;   if (self@end < self@start) {

&nbsp;     "@end must be >= @start"

&nbsp;   }

&nbsp; }

)



\# Usage - constructor and property access

x <- Range(start = 1, end = 10)

x@start  # 1

x@end <- 20  # automatic validation



\# Methods

inside <- new\_generic("inside", "x")

method(inside, Range) <- function(x, y) {

&nbsp; y >= x@start \& y <= x@end

}
```

\## OOP System Decision Matrix

\### S7 vs vctrs vs S3/S4 Decision Tree

\*\*Start here:\*\* What are you building?

\#### 1. \*\*Vector-like objects\*\* (things that behave like atomic
vectors)

    Use vctrs when:

    ✓ Need data frame integration (columns/rows)

    ✓ Want type-stable vector operations

    ✓ Building factor-like, date-like, or numeric-like classes

    ✓ Need consistent coercion/casting behavior

    ✓ Working with existing tidyverse infrastructure



    Examples: custom date classes, units, categorical data

\#### 2. \*\*General objects\*\* (complex data structures, not
vector-like)

    Use S7 when:

    ✓ NEW projects that need formal classes

    ✓ Want property validation and safe property access (@)

    ✓ Need multiple dispatch (beyond S3's double dispatch)

    ✓ Converting from S3 and want better structure

    ✓ Building class hierarchies with inheritance

    ✓ Want better error messages and discoverability



    Use S3 when:

    ✓ Simple classes with minimal structure needs

    ✓ Maximum compatibility and minimal dependencies

    ✓ Quick prototyping or internal classes

    ✓ Contributing to existing S3-based ecosystems

    ✓ Performance is absolutely critical (minimal overhead)



    Use S4 when:

    ✓ Working in Bioconductor ecosystem

    ✓ Need complex multiple inheritance (S7 doesn't support this)

    ✓ Existing S4 codebase that works well

\### Detailed S7 vs S3 Comparison

Feature \| S3 \| S7 \| When S7 wins \|

\|———\|—-\|—-\|—————\|

\*\*Class definition\*\* \| Informal (convention) \| Formal
(`new\_class()`) \| Need guaranteed structure \|

\*\*Property access\*\* \| `$` or
[`attr()`](https://rdrr.io/r/base/attr.html) (unsafe) \| `@` (safe,
validated) \| Property validation matters \|

\*\*Validation\*\* \| Manual, inconsistent \| Built-in validators \|
Data integrity important \|

\*\*Method discovery\*\* \| Hard to find methods \| Clear method
printing \| Developer experience matters \|

\*\*Multiple dispatch\*\* \| Limited (base generics) \| Full multiple
dispatch \| Complex method dispatch needed \|

\*\*Inheritance\*\* \| Informal,
[`NextMethod()`](https://rdrr.io/r/base/UseMethod.html) \| Explicit
`super()` \| Predictable inheritance needed \|

\*\*Migration cost\*\* \| - \| Low (1-2 hours) \| Want better structure
\|

\*\*Performance\*\* \| Fastest \| ~Same as S3 \| Performance difference
negligible \|

\*\*Compatibility\*\* \| Full S3 \| Full S3 + S7 \| Need both old and
new patterns \|

\### Practical Guidelines

\#### Choose S7 when you have:

``` r
\# Complex validation needs

Range <- new\_class("Range",

&nbsp; properties = list(start = class\_double, end = class\_double),

&nbsp; validator = function(self) {

&nbsp;   if (self@end < self@start) "@end must be >= @start"

&nbsp; }

)



\# Multiple dispatch needs  

method(generic, list(ClassA, ClassB)) <- function(x, y) ...



\# Class hierarchies with clear inheritance

Child <- new\_class("Child", parent = Parent)
```

\#### Choose vctrs when you need:

``` r
\# Vector-like behavior in data frames

percent <- new\_vctr(0.5, class = "percentage") 

data.frame(x = 1:3, pct = percent(c(0.1, 0.2, 0.3)))  # works seamlessly



\# Type-stable operations

vec\_c(percent(0.1), percent(0.2))  # predictable behavior

vec\_cast(0.5, percent())          # explicit, safe casting
```

\#### Choose S3 when you have:

``` r
\# Simple classes without complex needs

new\_simple <- function(x) structure(x, class = "simple")

print.simple <- function(x, ...) cat("Simple:", x)



\# Maximum performance needs (rare)

\# Existing S3 ecosystem contributions
```

\### Migration Strategy

1\. \*\*S3 → S7\*\*: Usually 1-2 hours work, keeps full compatibility

2\. \*\*S4 → S7\*\*: More complex, evaluate if S4 features are actually
needed

3\. \*\*Base R → vctrs\*\*: For vector-like classes, significant
benefits

4\. \*\*Combining approaches\*\*: S7 classes can use vctrs principles
internally

\## Package Development Decision Guide

\### Dependency Strategy

\#### When to Add Dependencies vs Base R

``` r
\# Add dependency when:

✓ Significant functionality gain

✓ Maintenance burden reduction

✓ User experience improvement

✓ Complex implementation (regex, dates, web)



\# Use base R when:

✓ Simple utility functions

✓ Package will be widely used (minimize deps)

✓ Dependency is large for small benefit

✓ Base R solution is straightforward



\# Example decisions:

str\_detect(x, "pattern")    # Worth stringr dependency

length(x) > 0              # Don't need purrr for this

parse\_dates(x)             # Worth lubridate dependency  

x + 1                      # Don't need dplyr for this
```

\#### Tidyverse Dependency Guidelines

``` r
\# Core tidyverse (usually worth it):

dplyr     # Complex data manipulation

purrr     # Functional programming, parallel

stringr   # String manipulation

tidyr     # Data reshaping



\# Specialized tidyverse (evaluate carefully):

lubridate # If heavy date manipulation

forcats   # If many categorical operations  

readr     # If specific file reading needs

ggplot2   # If package creates visualizations



\# Heavy dependencies (use sparingly):

tidyverse # Meta-package, very heavy

shiny     # Only for interactive apps
```

\### API Design Patterns

\#### Function Design Strategy

``` r
\# Modern tidyverse API patterns



\# 1. Use .by for per-operation grouping

my\_summarise <- function(.data, ..., .by = NULL) {

&nbsp; # Support modern grouped operations

}



\# 2. Use {{ }} for user-provided columns  

my\_select <- function(.data, cols) {

&nbsp; .data |> select({{ cols }})

}



\# 3. Use ... for flexible arguments

my\_mutate <- function(.data, ..., .by = NULL) {

&nbsp; .data |> mutate(..., .by = {{ .by }})

}



\# 4. Return consistent types (tibbles, not data.frames)

my\_function <- function(.data) {

&nbsp; result |> tibble::as\_tibble()

}
```

\#### Input Validation Strategy

``` r
\# Validation level by function type:



\# User-facing functions - comprehensive validation

user\_function <- function(x, threshold = 0.5) {

&nbsp; # Check all inputs thoroughly

&nbsp; if (!is.numeric(x)) stop("x must be numeric")

&nbsp; if (!is.numeric(threshold) || length(threshold) != 1) {

&nbsp;   stop("threshold must be a single number")

&nbsp; }

&nbsp; # ... function body

}



\# Internal functions - minimal validation  

.internal\_function <- function(x, threshold) {

&nbsp; # Assume inputs are valid (document assumptions)

&nbsp; # Only check critical invariants

&nbsp; # ... function body

}



\# Package functions with vctrs - type-stable validation

safe\_function <- function(x, y) {

&nbsp; x <- vec\_cast(x, double())

&nbsp; y <- vec\_cast(y, double())

&nbsp; # Automatic type checking and coercion

}
```

\### Error Handling Patterns

``` r
\# Good error messages - specific and actionable

if (length(x) == 0) {

&nbsp; cli::cli\_abort(

&nbsp;   "Input {.arg x} cannot be empty.",

&nbsp;   "i" = "Provide a non-empty vector."

&nbsp; )

}



\# Include function name in errors

validate\_input <- function(x, call = caller\_env()) {

&nbsp; if (!is.numeric(x)) {

&nbsp;   cli::cli\_abort("Input must be numeric", call = call)

&nbsp; }

}



\# Use consistent error styling

\# cli package for user-friendly messages

\# rlang for developer tools
```

\### When to Create Internal vs Exported Functions

\#### Export Function When:

``` r
✓ Users will call it directly

✓ Other packages might want to extend it

✓ Part of the core package functionality

✓ Stable API that won't change often



\# Example: main data processing functions

export\_these <- function(.data, ...) {

&nbsp; # Comprehensive input validation

&nbsp; # Full documentation required

&nbsp; # Stable API contract

}
```

\#### Keep Function Internal When:

``` r
✓ Implementation detail that may change

✓ Only used within package

✓ Complex implementation helpers

✓ Would clutter user-facing API



\# Example: helper functions

.internal\_helper <- function(x, y) {

&nbsp; # Minimal documentation

&nbsp; # Can change without breaking users

&nbsp; # Assume inputs are pre-validated

}
```

\### Testing and Documentation Strategy

\#### Testing Levels

``` r
\# Unit tests - individual functions

test\_that("function handles edge cases", {

&nbsp; expect\_equal(my\_func(c()), expected\_empty\_result)

&nbsp; expect\_error(my\_func(NULL), class = "my\_error\_class")

})



\# Integration tests - workflow combinations  

test\_that("pipeline works end-to-end", {

&nbsp; result <- data |> 

&nbsp;   step1() |> 

&nbsp;   step2() |>

&nbsp;   step3()

&nbsp; expect\_s3\_class(result, "expected\_class")

})



\# Property-based tests for package functions

test\_that("function properties hold", {

&nbsp; # Test invariants across many inputs

})
```

\#### Documentation Priorities

``` r
\# Must document:

✓ All exported functions

✓ Complex algorithms or formulas

✓ Non-obvious parameter interactions

✓ Examples of typical usage



\# Can skip documentation:

✗ Simple internal helpers

✗ Obvious parameter meanings

✗ Functions that just call other functions
```

\## Migration Notes

\### From Base R to Modern Tidyverse

``` r
\# Data manipulation

subset(data, condition)          -> filter(data, condition)

data\[order(data$x), ]           -> arrange(data, x)

aggregate(x ~ y, data, mean)    -> summarise(data, mean(x), .by = y)



\# Functional programming

sapply(x, f)                    -> map(x, f)  # type-stable

lapply(x, f)                    -> map(x, f)



\# String manipulation  

grepl("pattern", text)          -> str\_detect(text, "pattern")

gsub("old", "new", text)        -> str\_replace\_all(text, "old", "new")

substr(text, 1, 5)              -> str\_sub(text, 1, 5)

nchar(text)                     -> str\_length(text)

strsplit(text, ",")             -> str\_split(text, ",")

paste0(a, b)                    -> str\_c(a, b)

tolower(text)                   -> str\_to\_lower(text)
```

\### From Old to New Tidyverse Patterns

``` r
\# Pipes

data %>% function()             -> data |> function()



\# Grouping (dplyr 1.1+)

group\_by(data, x) |> 

&nbsp; summarise(mean(y)) |> 

&nbsp; ungroup()                     -> summarise(data, mean(y), .by = x)



\# Column selection

across(starts\_with("x"))        -> pick(starts\_with("x"))  # for selection only



\# Joins

by = c("a" = "b")              -> by = join\_by(a == b)



\# Multi-row summaries

summarise(data, x, .groups = "drop") -> reframe(data, x)



\# Data reshaping

gather()/spread()               -> pivot\_longer()/pivot\_wider()



\# String separation (tidyr 1.3+)

separate(col, into = c("a", "b")) -> separate\_wider\_delim(col, delim = "\_", names = c("a", "b"))

extract(col, into = "x", regex)   -> separate\_wider\_regex(col, patterns = c(x = regex))
```

\### Performance Migrations

``` r
\# Old -> New performance patterns

for loops for parallelizable work -> map(data, in\_parallel(f))

Manual type checking             -> vec\_assert() / vec\_cast()

Inconsistent coercion           -> vec\_ptype\_common() / vec\_c()



\# Superseded purrr functions (purrr 1.0+)

map\_dfr(x, f)                   -> map(x, f) |> list\_rbind()

map\_dfc(x, f)                   -> map(x, f) |> list\_cbind()

map2\_dfr(x, y, f)               -> map2(x, y, f) |> list\_rbind()

pmap\_dfr(list, f)               -> pmap(list, f) |> list\_rbind()

imap\_dfr(x, f)                  -> imap(x, f) |> list\_rbind()



\# For side effects

walk(x, write\_file)             # instead of for loops

walk2(data, paths, write\_csv)   # multiple arguments
```

This document should be referenced for all R development to ensure
modern, performant, and maintainable code.
