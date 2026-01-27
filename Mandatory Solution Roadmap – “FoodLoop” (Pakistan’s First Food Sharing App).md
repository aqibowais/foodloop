## FoodLoop – Pakistan’s First Food Sharing App  
**Hackathon: AI Fest 5.0 – App Development**  
**Domain:** Environmental Sustainability & Climate Action (SDG 13)

---

## 1. Problem Identification

### 1.1 Who is affected?

**Primary users**

- **Individual Donors**  
  Urban households, students, working professionals, restaurants, bakeries, event hosts with surplus food (near-expiry packaged items or freshly cooked leftovers).

- **Receivers (including NGOs)**  
  - Low-income individuals and families who cannot regularly afford meals.  
  - **NGOs / food banks / community kitchens** who collect surplus food and redistribute it in communities.  
  (NGOs are modelled as *receivers* in the system, not a separate role.)

**Secondary users**

- Event venues, caterers, wedding halls, corporate cafeterias.
- Local governments and municipal waste management authorities.
- Environmental and social-impact organisations.
- Corporate CSR teams and sponsors.

### 1.2 Why does this problem exist? (Root causes)

- **Awareness & stigma**
  - People underestimate the climate impact of throwing away edible food.
  - Cultural taboos and misconceptions about “food reuse” and consuming leftovers.

- **Coordination gap**
  - No simple, fast way to connect donors (households, events, restaurants) with receivers (NGOs and individuals) in real time.
  - Current methods (WhatsApp groups, phone calls) are ad-hoc, unstructured, and often too slow.

- **Trust & quality assurance**
  - Receivers and NGOs lack visibility into food quality, expiry, and safety.
  - Donors fear complaints or blame if the food quality is not acceptable.

- **Infrastructure issues**
  - No centralised view of surplus food in a city.
  - No data or tools to help NGOs prioritise pickups based on urgency and proximity.

### 1.3 What happens if not solved? (Consequences & urgency)

- **Environmental impact**
  - Edible food ends up in landfills, producing methane and contributing to climate change.
  - Wasted energy, water, and land used to produce food that is never eaten.

- **Social impact**
  - People remain food insecure while good food is thrown away.
  - Lost opportunity to build a sharing culture and social solidarity.

- **Economic impact**
  - Increased cost and burden on municipal waste systems.
  - NGOs spend more time searching for donations instead of distributing them efficiently.

- **Long-term**
  - Wasteful consumption habits become normalised.
  - Pakistan lags on SDG 12 (Responsible Consumption) and SDG 13 (Climate Action).

---

## 2. Stakeholder Analysis

### 2.1 Primary users (direct beneficiaries)

- **Donors**
  - Individuals, families, students, restaurants, bakeries, event hosts.
  - Use the app to list surplus food and coordinate pickups.

- **Receivers (including NGOs)**
  - Low-income individuals and families searching for free or low-cost food nearby.
  - **NGOs and community organisations** using the same “Receiver” role to receive bulk surplus and distribute it further.

- **Admins (platform moderators)**
  - Manage user reports and complaints.
  - Monitor suspicious activity and handle misuse.
  - Oversee platform health and impact.

### 2.2 Secondary users (indirect stakeholders)

- Event venues, caterers, and wedding planners.
- Local government and municipal waste authorities.
- Community leaders, mosques, and social welfare organisations.
- Corporate CSR departments and sponsors.

### 2.3 Institutions / communities / authorities involved

- Registered NGOs and charitable trusts.
- Environmental NGOs and SDG-focused organisations.
- Universities, schools, and corporate offices (for awareness and pilots).
- City governments and waste management departments.

### 2.4 Potential partnerships / integrations

- **Partnerships**
  - Leading local NGOs / food banks for distribution.
  - Associations of caterers, restaurants, and event venues.
  - Universities and corporates for internal pilot rollouts.

- **Integrations (current & future)**
  - Map APIs for location and distance calculation.
  - Cloudinary for image storage and optimisation.
  - (Future) SMS / WhatsApp APIs for alerts in low-data scenarios.

---

## 3. Proposed Solution

### 3.1 What does the app do? (Core functionality)

FoodLoop is a mobile app where individuals, restaurants, and event hosts in Pakistan can **list surplus food** (near-expiry packaged items or fresh leftovers) so that **nearby receivers—including NGOs—can claim and collect it for free or at minimal cost**. The app handles **listing, discovery, matching, pickup coordination, basic safety checks, and complaint resolution**, while tracking impact such as **food saved** and **approximate people fed**.

### 3.2 Why mobile-first?

- **Real-time and location-based**: Surplus food is time-sensitive; mobile phones provide GPS and instant notifications.
- **High smartphone penetration**: Most donors and many receivers, including NGO workers, use Android phones.
- **On-the-go usage**: Donors can list items immediately after events or while cleaning their fridge; receivers and NGOs can respond while on the move.
- **Camera integration**: Needed for capturing photos of food and labels for AI-based and OCR-based checks (expiry, visual condition).

### 3.3 Competitive advantage

- Tailored for the **Pakistani context** (events, cultural habits, localities, languages).
- **Unified workflow**: Individual receivers and NGOs both operate under a single “Receiver” role, simplifying design and onboarding.
- Early integration of **AI-based assistance**:
  - Expiry date detection (OCR).
  - Visual checks for food condition (future).
- Strong emphasis on **behaviour change** and **positive reinforcement** (impact stats, motivational messages).

### 3.4 Value proposition

- **For donors**:  
  Quick, guilt-free way to avoid waste, help others, and see their positive impact.

- **For receivers (including NGOs)**:  
  Easy discovery of nearby food, with visibility into quality, location, and pickup timing.

- **For the environment and society**:  
  Concrete reduction in food waste and emissions, plus cultural shift towards responsible consumption.

---

## 4. Core Features (MVP Focus)

### 4.1 Must-have features (24-hour MVP)

1. **User Registration & Roles**
   - Sign up / login via email or phone (Firebase Auth).
   - Choose role: `Donor` or `Receiver`.  
   - NGOs register as **Receivers** (option to mark “Organisation/NGO” in profile for admin tracking, but no separate role).
   - Basic profile: name, contact, city/area, optional organisation name.

2. **Food Listing Creation (Donor side)**
   - Donors can create a listing with:
     - Food type (cooked / packaged).
     - Title and description.
     - Approximate quantity / number of servings.
     - Expiry or “best before” date/time.
     - Location (map pin or area name).
     - Image(s) of food / packaging uploaded via **Cloudinary**.
   - Initial status: `Available`.

3. **Food Discovery & Request (Receiver side)**
   - Receivers (including NGOs) can:
     - View a list (and/or simple map) of nearby **Available** listings.
     - Filter and sort by distance, urgency (expiry time), and food type.
   - Receivers can open listing details and send a **Request**.
   - Donor receives notification and can **Accept** or **Reject**.
   - Once accepted:
     - Listing becomes `Reserved` for that receiver.
     - Pickup details shared (location, contact, time window).

4. **Completion & Basic Complaint Handling**
   - After pickup:
     - Donor or receiver marks listing as `Completed`.
   - If there is an issue (e.g., spoiled food, no-show):
     - Receiver can file a **complaint** linked to the listing.
   - Admin view:
     - See list of complaints with user info and listing details.
     - Mark complaints as `Under Review` / `Resolved`.
     - Option to warn or block repeat offenders.

5. **Impact & Motivation (Basic Dashboard)**
   - For each donor:
     - Number of completed donations.
     - Approximate meals served (based on quantity field).
   - For receiver/NGO:
     - Number of successful pickups.
   - Motivational lines (e.g., “You helped avoid food waste today”, “Total meals shared so far”).

6. **Ratings & Trust Layer**
   - Simple rating system for donors and receivers.
   - Helps NGOs and individuals identify reliable partners.

### 4.2 Future Plans (Post-Hackathon)

1. **Mass Event Mode & Auto Alerts for NGOs (as Receivers)**
   - Special “Event Listing” type for weddings/parties.
   - When created, nearby Receivers marked as NGOs (based on profile flag) get **priority alerts**.
   - First NGO to confirm gets reservation; others see it as reserved.

2. **AI-Based Food Quality Assistance**
   - OCR to automatically read expiry dates from package photos.
   - Basic classification or heuristic checks on food images to flag obviously unsafe items.
   - Future: risk scoring, guidance messages (“Consume within X hours”).

3. **Advanced Impact Analytics & Gamification**
   - Kg of food saved.
   - Estimated CO₂ emissions avoided.
   - Donor levels, badges, streaks, leaderboards.

4. **Multi-language Support**
   - English and Urdu initially; extend to more regional languages later.

---

## 5. Data & Scalability

### 5.1 Data collected / processed

- **User data**
  - Name, email/phone, role (Donor / Receiver), city/area.
  - Optional organisation name (for NGO receivers).
  - Basic activity counts (donations, pickups).

- **Listing data**
  - Food type, description, quantity, expiry/time window.
  - Location (city + coordinates/area).
  - Image URLs (stored on **Cloudinary**).
  - Status (`Available`, `Reserved`, `Completed`, `Expired`).

- **Request & transaction data**
  - Who requested which listing.
  - Timestamps (request, accept, complete).
  - Outcome (completed / cancelled).

- **Complaint & moderation data**
  - Complaint reason and description.
  - Linked listing and users.
  - Admin actions and resolution status.

- **Analytics / impact data**
  - Aggregate counts of completed donations and approximate meals.
  - (Future) estimates of food weight and CO₂ saved.

### 5.2 Data storage approach

- **Cloud-backend (primary)**
  - **Firebase Auth**: user authentication.
  - **Cloud Firestore**: users, listings, requests, complaints, and stats.
  - **Cloudinary**: image uploads, storage, and optimisation of food photos (no Firebase Storage usage).

- **Local storage (secondary)**
  - Store minimal cached data and user preferences on device (e.g., role, language) for better UX.

### 5.3 Privacy & security

- Expose only necessary data:
  - Exact address/contact details visible only **after** a request is accepted.
- Role-based access via Firestore security rules:
  - Users can only edit their own profile and listings.
  - Receivers cannot modify others’ data.
  - Admins have elevated read / write rights for moderation.
- Encrypted transport (HTTPS).
- Encourage users not to upload images with faces or personal documents.
- Simple terms and guidelines explaining safe food sharing practices.

### 5.4 Scalability

- **Technical scalability**
  - Firebase and Cloudinary both scale well for early and mid-stage traffic.
  - Data models can be partitioned by city or region if needed.

- **Geographical scalability**
  - Start with one major city as a pilot.
  - Gradually onboard more cities with minimal changes (mostly configuration / localisation).

- **Use-case scalability**
  - Extend from individual donations to:
    - Supermarkets and bakeries listing near-expiry items.
    - Corporate cafeterias and university canteens.

### 5.5 Infrastructure for growth

- **Phase 1 (Hackathon/Pilot)**
  - Single Firebase project and Cloudinary account.
  - Basic in-app dashboards and use of Firebase console for monitoring.

- **Phase 2 (City-wide expansion)**
  - Firestore indexes and query optimisation.
  - Cloud Functions for scheduled expiry checks and stats aggregation.

- **Phase 3 (Multi-city / national)**
  - Optional dedicated backend for advanced AI and analytics.
  - Stronger observability and security hardening.

---

## 6. SDG Impact Mapping

### 6.1 SDGs addressed

- **Primary:**  
  - **SDG 13 – Climate Action** (reducing methane emissions from food waste).

- **Secondary:**  
  - **SDG 2 – Zero Hunger** (increasing access to food for vulnerable populations).  
  - **SDG 12 – Responsible Consumption and Production** (promoting food reuse and anti-waste culture).

### 6.2 Success metrics

- **Environmental**
  - Number of completed donations.
  - Estimated kg of food diverted from waste (based on quantity field).
  - (Future) Estimated CO₂ emissions avoided.

- **Social**
  - Approximate number of meals served.
  - Number of unique active donors and receivers (including NGOs).

- **Behavioural**
  - Repeat donors (e.g., 3+ donations).
  - Average time from listing creation to pickup.

### 6.3 Short-term impact (within 6 months)

- Pilot in one major city with:
  - 500–1,000 registered users.
  - 50+ active receivers (including NGOs).
  - 100+ completed donations logged.
- Collect user and NGO feedback to refine UX, trust mechanisms, and safety guidelines.

### 6.4 Long-term vision (1–3 years)

- Operate in multiple cities across Pakistan.
- Become the standard platform for surplus food sharing and post-event redistribution.
- Use aggregated data to support national campaigns on food waste reduction.
- Contribute measurably to Pakistan’s progress on SDGs 2, 12, and 13.

---

## 7. Technical Stack Overview

- **Platform:** Android (APK for submission).  
- **Frontend:** Flutter (Dart).  
- **Backend:** Firebase (Auth, Firestore, Cloud Functions as needed).  
- **Image Storage & Optimisation:** **Cloudinary** (for listing images, transformations, and CDN).  
- **Maps & Location:** Google Maps / open alternative.  
- **AI & OCR (prototype / future):**
  - OCR for expiry date reading from labels.
  - Simple image-based quality checks or external AI APIs (future).

  
**Prepared for:** AI Fest 5.0 Hackathon  
**Date:** January 2026  
**Team:** [Re-Dart-ed]