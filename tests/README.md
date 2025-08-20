# Test Suite

```bash
Usage: lune run tests [benchmark] [options]

Options:
    --werror        Treat warnings as errors
    --help, -h      Display this text
```

## Exit Codes

| Exit Code     | Meaning                  |
| ------------- | ------------------------ |
| `0`           | Test passed              |
| `2`           | Test failed as a warning |
| Anything else | Test failed              |
