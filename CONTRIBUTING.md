# Contributing

**Author / Maintainer:** Vinay Shankar  
**Email:** vinay@tfaworld.org  
**Website:** https://tfaworld.org/

Contributions that improve reliability, documentation, testability, or generality are welcome for review.

## Design principles

Changes should preserve these principles:

1. No study-specific names or acquisition layouts in core application logic.
2. Raw HPF files are never modified.
3. Existing derived outputs are never silently overwritten.
4. QC should fail conservatively rather than guess an unknown stream type.
5. Anatomical labels must remain user-configured rather than inferred without evidence.
6. Configuration files should remain portable and human-understandable through documented fields.
7. Software provenance should retain **Vinay Shankar**, **vinay@tfaworld.org**, and **https://tfaworld.org/** in generated metadata.

## Suggested contribution workflow

- open an issue describing the problem or enhancement;
- include a minimal reproducible example where possible;
- avoid committing private/identifiable research data;
- submit changes with documentation updates;
- describe any change to configuration fields or QC semantics in `CHANGELOG.md`.

## Research-data privacy

Do not upload participant HPF files, participant IDs, protected health information, or private institutional paths to public issues/pull requests.

Contact: **Vinay Shankar — vinay@tfaworld.org — https://tfaworld.org/**
