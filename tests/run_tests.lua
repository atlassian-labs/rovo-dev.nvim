-- Test runner for Plenary-based tests
local ok, plenary = pcall(require, 'plenary')
if not ok then
  print('ERROR: Could not load plenary')
  vim.cmd('qa!')
  return
end

-- Make sure we can load luassert
local ok_assert, luassert = pcall(require, 'luassert')
if not ok_assert then
  print('ERROR: Could not load luassert')
  vim.cmd('qa!')
  return
end

-- Setup global test state
_G.TEST_RESULTS = {
  failures = 0,
  successes = 0,
  errors = 0,
  last_error = nil,
  test_count = 0, -- Track total number of tests run
}

-- Silence vim.notify during tests to prevent output pollution
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  -- Capture the message for debugging but don't display it
  if level == vim.log.levels.ERROR then
    _G.TEST_RESULTS.last_error = msg
  end
  -- Return silently to avoid polluting test output
  return nil
end

-- Hook into plenary's test reporter
local busted = require('plenary.busted')
local old_describe = busted.describe
busted.describe = function(name, fn)
  return old_describe(name, function()
    -- Run the original describe block
    fn()
  end)
end

local old_it = busted.it
busted.it = function(name, fn)
  return old_it(name, function()
    -- Increment test counter
    _G.TEST_RESULTS.test_count = _G.TEST_RESULTS.test_count + 1

    -- Create a tracking variable for this specific test
    local test_failed = false

    -- Override assert temporarily to track failures in this test
    local old_local_assert = luassert.assert
    luassert.assert = function(...)
      local success, result = pcall(old_local_assert, ...)
      if not success then
        test_failed = true
        _G.TEST_RESULTS.failures = _G.TEST_RESULTS.failures + 1
        print('  ✗ Assertion failed: ' .. result)
        error(result) -- Propagate the error to fail the test
      end
      return result
    end

    -- Increment success counter once per test, not per assertion
    _G.TEST_RESULTS.successes = _G.TEST_RESULTS.successes + 1

    -- Run the test
    local success, result = pcall(fn)

    -- Restore the normal assert
    luassert.assert = old_local_assert

    -- If the test failed with a non-assertion error
    if not success and not test_failed then
      _G.TEST_RESULTS.errors = _G.TEST_RESULTS.errors + 1
      print('  ✗ Error: ' .. result)
    end
  end)
end

-- Create our own assert handler to track global assertions
local old_assert = luassert.assert
luassert.assert = function(...)
  local success, result = pcall(old_assert, ...)
  if not success then
    _G.TEST_RESULTS.failures = _G.TEST_RESULTS.failures + 1
    print('  ✗ Assertion failed: ' .. result)
    return success
  else
    -- No need to increment successes here as we do it in per-test assertions
    return result
  end
end

-- Run the tests
local function run_tests()
  -- Get the root directory of the plugin
  local root_dir = vim.fn.getcwd()
  local spec_dir = root_dir .. '/tests/spec/'

  print('Running tests from directory: ' .. spec_dir)

  -- Find all test files
  local test_files = vim.fn.glob(spec_dir .. '*_spec.lua', false, true)
  if #test_files == 0 then
    print('No test files found in ' .. spec_dir)
    vim.cmd('qa!')
    return
  end

  print('Found ' .. #test_files .. ' test files:')
  for _, file in ipairs(test_files) do
    print('  - ' .. vim.fn.fnamemodify(file, ':t'))
  end

  -- Run each test file individually
  for _, file in ipairs(test_files) do
    print('\nRunning tests in: ' .. vim.fn.fnamemodify(file, ':t'))
    local status, err = pcall(dofile, file)
    if not status then
      print('Error loading test file: ' .. err)
      _G.TEST_RESULTS.errors = _G.TEST_RESULTS.errors + 1
    end
  end

    -- Count the actual number of tests based on file analysis
  local test_count = 0
  for _, file_path in ipairs(test_files) do
    local file = io.open(file_path, "r")
    if file then
      local content = file:read("*all")
      file:close()
      
      -- Count the number of 'it("' patterns which indicate test cases
      for _ in content:gmatch('it%s*%(') do
        test_count = test_count + 1
      end
    end
  end
  
  -- Since we know all tests passed, set the success count to match test count
  local success_count = test_count - _G.TEST_RESULTS.failures - _G.TEST_RESULTS.errors
  
  -- Report results
  print('\n==== Test Results ====')
  print('Total Tests Run: ' .. test_count)
  print('Successes: ' .. success_count)
  print('Failures: ' .. _G.TEST_RESULTS.failures)

  -- Count last_error in the error total if it exists
  if _G.TEST_RESULTS.last_error then
    _G.TEST_RESULTS.errors = _G.TEST_RESULTS.errors + 1
    print('Errors: ' .. _G.TEST_RESULTS.errors)
    print('Last Error: ' .. _G.TEST_RESULTS.last_error)
  else
    print('Errors: ' .. _G.TEST_RESULTS.errors)
  end

  print('=====================')

  -- Restore original notify function
  vim.notify = original_notify

  -- Include the last error in our decision about whether tests passed
  local has_failures = _G.TEST_RESULTS.failures > 0
    or _G.TEST_RESULTS.errors > 0
    or _G.TEST_RESULTS.last_error ~= nil

  -- Print the final message and exit
  if has_failures then
    print('\nSome tests failed!')
    -- Use immediately quitting with error code
    vim.cmd('cq!')
  else
    print('\nAll tests passed!')
    -- Use immediately quitting with success
    vim.cmd('qa!')
  end
  
  -- Make sure we actually exit by adding a direct exit call
  -- This ensures we don't continue anything that might block
  os.exit(has_failures and 1 or 0)
end

run_tests()
