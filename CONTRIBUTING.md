# Contributing to BAF RTS Food Canteen (Mobile)

Thank you for contributing to the **Bangladesh Air Force Recruits Training School (RTS) Food Canteen System**.

## Development Workflow

1. **Branching Strategy**:
   - `main`: Production-ready, stable releases.
   - `feature/<feature-name>`: New capabilities or screen additions.
   - `fix/<bug-name>`: Bug fixes and dark mode / layout adjustments.

2. **Commit Policy (Conventional Commits)**:
   All commits must follow the conventional commit structure:
   - `feat(...)`: New user-facing feature or enhancement
   - `fix(...)`: Bug fix or styling correction
   - `refactor(...)`: Code cleanup or restructuring
   - `test(...)`: Unit, widget, or integration tests
   - `docs(...)`: Documentation updates

3. **Pre-Commit Checks**:
   Always run static analysis and tests locally before pushing:
   ```bash
   flutter analyze
   flutter test
   ```
   Both checks must pass with zero errors.

4. **Code Guidelines**:
   - Adhere to military color tokens in `lib/core/theme/app_colors.dart`.
   - Never hardcode bright white backgrounds in dark mode surfaces.
   - Keep touch targets accessible on compact mobile screens (minimum 360px width).
