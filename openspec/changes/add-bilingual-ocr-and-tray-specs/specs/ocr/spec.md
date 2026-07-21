# Capability: OCR Language Selection

## Added Requirements

### Requirement: Dual Russian and English Hybrid Mode
The OCR engine SHALL support a hybrid language option `RU+` (`rus+eng`) in the language selection dropdown.

#### Scenario: Selecting RU+ Mode
- **GIVEN** the user opens the language selector dropdown
- **WHEN** the user selects "Russian + English" (`RU+`)
- **THEN** Tesseract OCR SHALL evaluate both Russian (`rus`) and English (`eng`) language models simultaneously on the captured image.
