# Billing profile updates

`applyProfilePatch(stored, patch)` returns the updated profile without modifying `stored`.

- A field absent from the patch (or `undefined`) keeps its stored value.
- `email` is trimmed and lowercased, and must look like an address; otherwise `ProfileError` with `field: "email"`.
- `country` is trimmed and uppercased, and must be one of `BR`, `US`, `PT`, `DE`; otherwise `ProfileError` with `field: "country"`.
- `companyName` and `taxId` are optional: text is trimmed; `null` or blank text clears the field (`null`).
