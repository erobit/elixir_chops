## Table of contents

- [General info](#general-info)
- [Frameworks](#Frameworks)
- [Application features](#application-features)
- [Thank you](#thank-you)

## General info

This project demonstrates samples of code that I have personally written in Elixir over the past few years.

`Note: the code will not compile or generate a working application as it has come from closed source elixir project(s) and has been stripped of any domain specific functionality so that it could be shared with you today.`

It however, should give you a feel for my coding capabilities in Elixir, and there are many features that are directly applicable to your e-commerce domain.

## Frameworks

- Elixir: 1.7.3
- Phoenix: 1.3.4

`Note: I have already spent time learning LiveView (w/ ui components!) along with OTP services. I'm itching for the opportunity to use them on a new project!`

## Application features

**apps/store/lib/store**

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

**apps/store-api/lib/web**

- plugs
  - A large number of API endpoints to manage all types of cool things
    - Authentication for web,mobile
    - Handling API return URLs from SMS providers
- types, schemas, resolvers
  - GraphQL API (absinthe) goodies

**.circleci**

- Building and deploying Elixir using docker containers via circle-ci
- I'm also highly competent in AWS cloud services / DevOps functions!

## Thank you!

Thank you for your taking the time to review this sample Elixir work. I look forward to answering any questions you may have about anything Elixir, and I'm excited to learn more about how I can help you achieve your Elixir development goals!
