-- Luacheckrc for Rovo Dev plugin

std = {
  globals = {
    "vim",
    "table",
    "string",
    "math",
    "os",
    "io",
  },
  read_globals = {
    "jit",
    "require",
    "pcall",
    "type",
    "ipairs",
    "pairs",
    "tostring",
    "tonumber",
    "error",
    "assert",
    "_VERSION",
  },
}

-- Patterns for files to exclude
exclude_files = {
  ".luarocks/*",
  "lua/plenary/*",
  "tests/plenary/*",
}

-- Special configuration for scripts
files["scripts/**/*.lua"] = {
  globals = {
    "print", "arg",
  },
}

-- Special configuration for test files
files["tests/**/*.lua"] = {
  -- Allow common globals used in testing
  globals = {
    -- Common testing globals
    "describe", "it", "before_each", "after_each", "teardown", "pending", "spy", "stub", "mock",
    -- Lua standard utilities used in tests
    "print", "dofile",
    -- Test helpers
    "test", "expect",
    -- Global test state (allow modification)
    "_G",
  },

  -- Define fields for assert from luassert
  read_globals = {
    assert = {
      fields = {
        "is_true", "is_false", "is_nil", "is_not_nil", "equals",
        "same", "near", "matches", "has_error",
        "truthy", "falsy", "has", "has_no", "is_string", "is_number",
        "is_function", "is_table"
      }
    }
  },

  -- For test files only, ignore unused arguments as they're often used for mock callbacks
  unused_args = false,
}

-- Allow unused self arguments of methods
self = false

-- Don't report unused arguments/locals
unused_args = false
unused = false

-- We don't ignore any warnings - all code style issues should be fixed
ignore = {
  -- No ignored warnings
}

-- Maximum line length
max_line_length = 120

-- Maximum cyclomatic complexity of functions
max_cyclomatic_complexity = 20

-- Override settings for specific files
files["lua/rovo-dev/config.lua"] = {
  max_cyclomatic_complexity = 30, -- The validate_config function has high complexity due to many validation checks
}
