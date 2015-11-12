(c) 2015 Citizen Code LLC

This is a draft of the license we are exploring using. Give us feedback on if you would be interested in using the software with these or similar terms.

----
# Peer Production Royalty Token License (PPRT)
### *v0.01 (experimental - don't use this yet)*

(c) [Year] [Person or organization]

By using or contributing to this version of the code repository you agree to the following contract.

## TERMS OF USE

Permission is hereby granted, IN EXCHANGE FOR THE ROYALTY PERCENTAGE DERIVED FROM THIS SOFTWARE'S USE AND PAID PRORATA TO ROYALTY SHARING TOKEN HOLDERS, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Contributions

If you submit a contribution to the repository, you grant to the repository copyright holder and to recipients of the repository contents a perpetual, worldwide, non-exclusive, no-charge, royalty-free, irrevocable copyright and patent license to reproduce, prepare derivative works of, publicly display, publicly perform, sublicense, and distribute Your Contributions and such derivative works free of any charge separate from any Royalty Token's granted in exchange for your contribution.

You represent that you are legally entitled to grant the above license. If your employer(s) has rights to intellectual property that you create that includes your Contributions, you represent that you have received permission to make Contributions on behalf of that employer, that your employer has waived such rights for your Contributions.

## Repository Specific Agreements

### Statement of Intent

Core Committers agree to this intent.

#### Why
#### What
#### How

### Core Contributors

[Names of individual contributors who are part of the decision making process]

### Royalties

7.5% of gross revenue derived from the sale, hosting, or distribution of this software will be shared with the Royalty Token Holders on a prorata basis.

The following persons or legal entities are exempt from this royalty payment:
* [you can put something here like non-profits or a list of linked projects]

### Royalty Token Bounties

Core Contributors can accept repository contributions and issue bounties autonomously without a governance process. Only work accepted by a Core Contributor receives a bounty.

```
Bounty Award = Base Bounty x Quality x Risk Factor
```

"Risk Factor"

- (3) if less than $5,000 in royalties has been distributed to stakeholders in the last year.
- (2) if $5,000 to $100,000 in royalties have been distributed in the last year.
- (1) if more than $100,000 in royalties have been distributed in the last year.

"Base Bounty" amount denominated in RSTs for contributions accepted by Core Contributors is:
- (25) for an issue estimated at small size
- (100) for an issue estimated at medium size
- (500) for an issue estimated at large size
- (250) per week for being a Core Contributor (developer, product manager, designer, or community manager). Note product managers also receive a portion of issues they create that have been completed.
- 0.25x bounty is given to the creator of an accepted issue. This is intended for product managers and community contributions.

"Quality" multiples:
- 1.5x bounty multiple for increasing community knowledge, collaboration, design cohesion, and code quality on an issue through a collaborative submission (e.g. pair programming, design / dev pair). These bounties will be split between the submitters.
- 2x bounty multiple for commits that include test coverage.


In the interest of furthering the intent of the project, Core contributors can distribute up to 250 RSTs times the current Risk Factor to anyone other than themselves per week. This permission does not accumulate from week to week.

The bounty amounts can be modified through Core Contributor proposal process. Larger bounties (e.g. for large contributions) can be granted through the Core Contributor proposal process.

Once an RST bounty has been awarded and recorded in the Royalty Sharing Token Table, these RSTs can only be transferred by permission or request of the RST owner.

### Royalty Sharing Token Table

One canonical RST Table will be used to track ownership of Revenue Sharing Tokens. It will be available and reasonably accessible to all RST holders. Core Contributors are responsible for furnishing the latest RST Table data to any RST holder that requests it.

By default the RST Table will be tracked in the initial designated origin master repository accessible to all Core Contributors. A new Royalty Sharing Token Table may be designated through a proposal by Core Contributors as long the existing Royalty Token Ownership is migrated to the new system of record.

| Contributor | Revenue Sharing Tokens (RSTs)    |
| :------------- | :------------- |
|                 | 0       |

## Governance

Core Contributors may make proposals to:
- Add another Core Contributor
- Remove another Core Contributor
- Modify royalty or default bounty amounts for versions of the repository created after the proposal is adopted.
- Core Contributors may propose a "Revenue Sharing Token Fork". This is different than simply forking and extending the repository as a user.

In the case of a "Revenue Sharing Token Fork" the new repository will begin with a duplicate of old Royalty Token Table distribution. New Core Contributors to the repository will be proposed and determined by the original Core Contributors. If this occurs then the forked repository may dynamically issue RSTs that only apply to the royalty distribution table for the new repository.

## Proposal Process

Each Core Contributor may have their vote counted once for each product proposal. They are free to alter their vote prior to the quorum required for proposal adoption. Proposals, votes, and written dialog about proposals are public to all Royalty Sharing Token holders and Core Committers.

1. The proposer (who must be a Core Contributor) creates a new pull request with the proposal. The tension to be addressed by the proposal is included in the commit message.
1. Core Contributors respond with clarifications, reactions, and a vote of "+1", "+0", or "-1". To constructively accommodate potential disinterest, any Core Contributor can abstain from participating.
1. Anyone can request that the proposal be discussed on a phone call or video call.
1. The proposal is adopted immediately if all Core Contributors respond with either +1 or +0.
1. The proposal is adopted if less than 25% of Core Contributors respond "-1" within 2 weeks of the initial proposal pull request.

## Hall of Shame

Public shaming reduces enforcement costs for all license users. Companies who have not paid their royalties for this license are listed here:
[list]
