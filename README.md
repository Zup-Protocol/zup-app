# Zup App

Zup App repository is the repository containing the Zup Protocol Web Application.

# Getting Started

## Dependencies

- **Flutter/FVM**

  - To run the app, you will need to have Flutter installed on your computer. The current version of Flutter used by Zup App is `3.29.2`.
  - You can check if Flutter is installed, or the Flutter version by running `flutter --version` on your terminal, you should see a response like `Flutter X.XX.X`.
  - If the Flutter is not installed, or the version differs from the version used by Zup App, you can install Flutter from FVM (To allow you have multiple Flutter versions in your computer)
  - [How to install FVM](https://fvm.app/documentation/getting-started/installation)
  - To install Flutter from FVM, run `fvm install [FLUTTER_VERSION]`

- **Dart**

  - You will need to have Dart installed on your computer. Currently, Dart comes with Flutter. So no additional installation is required if you have Flutter installed.
  - The current version of Dart used by Zup App is `3.5.2` or higher. You can check your Dart version by running `dart --version` on your terminal, you should see a response like `Dart SDK version: X.X.X`.

- **GNU Make**
  - To check if Make is installed, run `make --version`. You should see a response like `GNU Make x.xx`.
  - If Make is not installed, visit the [GNU Make website](https://www.gnu.org/software/make/) for installation instructions.
  - Make will be used to run pre-defined commands in a Makefile. is not mandatory to run the App, but it will make the development process easier.

## Installation

1. Clone the repository: `git clone https://github.com/Zup-Protocol/zup-app.git`
2. Run `make install`
3. Nothing else to do! You are ready to go!

## Running Tests

Running tests is as simple as running `make test` in your terminal, at the root of the repository.

# Deploying

This app is hosted on Vercel. To trigger a deployment, just push changes to the branch that you want to deploy. Pushing changes to the main branch, will cause a production deployment.

## Steps Before Deploying in Production

Before making a deployment to production, that are a few steps that you need to do to make the deployment more smooth to the user.

1. Update the Flutter bootstrap build version in the [index.html](web/index.html) file to the next version. This prevents users from seeing a cached version of the app (old version), as Flutter Web does not currently handle caching automatically. This manual update serves as a workaround.
   ```diff
   -flutter_bootstrap.js?v=1
   +flutter_bootstrap.js?v=2
   ```
2. That's it! You're ready to deploy to production!
