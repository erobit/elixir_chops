## Table of contents

- [General info](#general-info)
- [Tech Stack](#tech-stack)
- [Application features](#application-features)
- [Thank you](#thank-you)

## General info

This project demonstrates Elixir code I have personally authored over the past few years.

`Note: The code will not compile and generate a working application as it has come from closed source elixir project(s) which have been stripped of any domain specific functionality so that it could be shared with you.`

You should however, be able to get a feel for my coding capabilities in Elixir. There are many sample application features that I have shared that are directly applicable to your e-commerce domain.

## Tech Stack

- Elixir
- Phoenix
- GraphQL
- PostgreSQL
- Docker

`Note: I have a very good grasp of LiveView (ui components & slots) along with OTP services. I'm itching for the opportunity to use them on a new project!`

## Application features

[apps/store/lib/store](https://github.com/erobit/elixir_chops/tree/main/apps/store/lib/store)

- inventory
  - Product management and integration with third party product providers
- billing
  - PaySafe and transaction processing
- loyalty
  - memberships, referrals, rewards
- plivo, twilio, nexmo, brightlink
  - Third Party SMS API integrations
- aws
  - S3 integration

[apps/store-api/lib/web](https://github.com/erobit/elixir_chops/tree/main/apps/store_api/lib/store_api/web)

- plugs
  - A large number of API endpoints to manage all types of cool things
    - Authentication for web,mobile
    - Handling API return URLs from SMS providers
- types, schemas, resolvers
  - GraphQL API (absinthe) goodies

**.circleci**

- Building and deploying Elixir using docker containers via circle-ci
- I'm also highly competent in AWS cloud services / DevOps related functions

## Thank you!

Thank you for your taking the time to review this sample Elixir work. I look forward to answering any questions you may have, and I'm excited to learn more about how I can help you achieve your Elixir development goals!

_Note: This repository is shared publicly only for the consideration of work opportunities. All rights are reserved to the author for the code that lies herein._
