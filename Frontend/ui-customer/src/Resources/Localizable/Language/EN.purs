{-
 
  Copyright 2022-23, Juspay India Pvt Ltd
 
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 
  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program
 
  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 
  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of
 
  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module EN where

import Language.Types (STR(..))
import Prelude ((<>))

getEN :: STR -> String
getEN script = case script of 
  DOWNLOAD_INVOICE -> "Download Invoice"
  REPORT_AN_ISSUE -> "Report an issue"
  SUBMIT -> "Submit"
  VIEW_INVOICE -> "View Invoice"
  TOTAL_AMOUNT -> "Total Amount"
  AMOUNT_PAID -> "Amount Paid"
  TRIP_DETAILS_ -> "Trip Details"
  DOWNLOAD_PDF -> "Download PDF"
  GST -> "GST"
  INVOICE -> "Invoice"
  TRIP_CHARGES -> "Trip Charges"
  PROMOTION -> "Promotion"
  SEND_EMAIL -> "Send Email"
  YOU_CAN_DESCRIBE_THE_ISSUE_YOU_FACED_HERE -> "You can describe the issue you faced here"
  THANK_YOU_FOR_WRITING -> "Thank You for writing to us!"
  WE_HAVE_RECEIVED_YOUR_ISSUE -> "We have received your issue. We’ll reach out to you in sometime."
  GO_HOME_ -> "Go Home"
  LOGO -> "Logo"
  ABOUT_APP_DESCRIPTION -> "Namma Yatri is an open platform to connect riders with drivers. The app makes it convenient for riders to book a ride with meter rate hence minimal fare."
  ABOUT -> "About"
  PRIVACY_POLICY -> "Privacy Policy"
  SET_UP_YOUR_ACCOUNT -> "Set up your account"
  CONTINUE -> "Continue"
  ENTER_YOUR_NAME -> "Enter Your Name"
  FULL_NAME-> "Full Name"
  EMAIL -> "Email"
  WELCOME_TO_NAMMA_YATRI -> "Welcome to Namma Yatri"
  PLEASE_CHOOSE_YOUR_PREFERRED_LANGUAGE_TO_CONTINUE -> "Please choose your preferred language to continue."
  WRITE_TO_US -> "Write to Us"
  NOTE -> "Note: "
  VISIT_MY_RIDES_SECTION_FOR_RIDE_SPECIFIC_COMPLAINTS -> "Visit My rides section for ride specific complaints"
  THANK_YOU_FOR_WRITING_TO_US -> "Thank You for writing to us!"
  WE_HAVE_RECEIVED_YOUR_ISSUE_WELL_REACH_OUT_TO_YOU_IN_SOMETIME -> "We have received your issue. We’ll reach out to you in sometime."
  GO_TO_HOME__ -> "Go To Home" 
  SUBJECT -> "Subject"
  YOUR_EMAIL_ID -> "Your email ID"
  DESCRIBE_YOUR_ISSUE -> "Describe your issue"
  ENTER_MOBILE_NUMBER -> "Enter Mobile number"
  BY_TAPPING_CONTINUE -> "By tapping continue"
  TO_THE -> "You agree that you are accepting the "
  ENTER_OTP -> "Enter OTP"
  RESEND -> "Resend"
  ENTER_YOUR_MOBILE_NUMBER -> "Enter your Mobile Number "
  LOGIN_USING_THE_OTP_SENT_TO -> "Login using the OTP sent to"
  YOUR_RECENT_RIDE -> "Your Recent Ride"
  VIEW_ALL_RIDES -> "View All Rides"
  ALL_TOPICS -> "All Topics"
  FAQ -> "FAQ"
  REPORT_AN_ISSUE_WITH_THIS_TRIP -> "Report an issue with this Trip"
  YOU_RATED -> "You Rated:"
  GETTING_STARTED_AND_FAQS -> "Getting started and FAQs"
  FOR_OTHER_ISSUES_WRITE_TO_US -> "For other issues, write to us"
  HELP_AND_SUPPORT -> "Help and Support"
  OUR_SUGGESTED_PRICE_FOR_THIS_TRIP_IS -> "Our suggested price for this trip is"
  DRIVERS_CAN_CHARGE_BETWEEN_THE_ABOVE_RANGE -> "*Drivers can charge between the above range"
  HOW_THIS_WORKS -> "How this works?"
  FINDING_RIDES_NEAR_YOU -> "Finding rides near you..."
  CONFIRMING_THE_RIDE_FOR_YOU -> "Confirming the ride for you..."
  CANCEL_SEARCH -> "Cancel Search"
  YOUR_RIDE_IS_NOW_COMPLETE -> "Your Ride is now complete!"
  PLEASE_PAY_THE_FINAL_AMOUNT_TO_THE_DRIVER_VIA_CASH -> "Please pay the final amount to the driver directly"
  WHERE_TO -> "Where to?"
  HOME ->  "Home"
  PICK_UP_LOCATION -> "Pick Up Location"
  REQUEST_RIDE -> "Request Ride"
  NAME -> "Name"
  MOBILE_NUMBER_STR -> "Mobile Number"
  PERSONAL_DETAILS -> "Personal Details"
  YOUR_RIDES -> "Your Rides"
  YOU_ARE_OFFLINE -> "You're Offline"
  CHECK_YOUR_INTERNET_CONNECTION_AND_TRY_AGAIN -> "Check your internet connection and try again"
  TRY_AGAIN -> "Try again"
  THANK_YOUR_DRIVER -> "Thank your Driver!"
  HOPE_YOUR_RIDE_WAS_HASSLE_FREE -> "We hope your ride was hassle free"
  HOW_WAS_YOUR_RIDE_WITH -> "How was your ride with "
  GOT_IT_TELL_US_MORE -> "Got it, Tell us more?"
  WRITE_A_COMMENT -> "Write a comment (Optional)"
  UPDATE -> "Update"
  LANGUAGE -> "Language"
  OTP -> "OTP"
  PAYMENT_METHOD -> "Payment Method"
  PAYMENT_METHOD_STRING -> "Cash / Use any UPI app"
  CANCEL_RIDE -> "Cancel Ride"
  SUPPORT -> "Support"
  PICKUP_AND_DROP -> "Pickup and drop"
  CANCELLED -> "Cancelled"
  HOW_THE_PRICING_WORKS -> "How the pricing works?"
  SELECT_AN_OFFER -> "Select an Offer"
  CHOOSE_A_RIDE_AS_PER_YOUR_COMFORT -> "Choose a ride as per your comfort "
  IT_SEEMS_TO_BE_A_VERY_BUSY_DAY -> "It seems to be a very busy day. You may try looking for rides again"
  SORT_BY -> "Sort By"
  SORRY_WE_COULDNT_FIND_ANY_RIDES -> "Sorry, we couldn’t find any rides"
  LOAD_MORE -> "Load More"
  WE_NEED_ACCESS_TO_YOUR_LOCATION -> "We need access to your location!"
  YOUR_LOCATION_HELPS_OUR_SYSTEM -> "Your location helps our system to map down all the near by autos and get you the quickest ride possible."
  CALL -> "Call"
  EMPTY_RIDES -> "Empty Rides"
  YOU_HAVENT_TAKEN_A_TRIP_YET -> "You haven't taken a trip yet"
  BOOK_NOW -> "Book Now"
  T_AND_C_A -> "a) You agree that you are a willing participant of the beta testing and Juspay shall have no liability against you in any respect"
  TERMS_AND_CONDITIONS -> "T&C"
  DATA_COLLECTION_AUTHORITY ->  "c) I hereby appoint and authorize Juspay to collect my information and by continuing, I agree to the Terms of Use and Privacy Policy."
  DENY_ACCESS -> "Deny Access"
  PLEASE_TELL_US_WHY_YOU_WANT_TO_CANCEL -> "Please tell us why you want to cancel"
  MANDATORY -> "Mandatory"
  SOFTWARE_LICENSE -> "Software license"
  LOGOUT_ -> "Logout"
  REQUEST_AUTO_RIDE -> "Request Auto Ride"
  RATE_YOUR_RIDE -> "Rate your ride"
  SKIP -> "Skip"
  ERROR_404 -> "Error 404"
  PROBLEM_AT_OUR_END -> "There seems to be a problem at our end. Get notified when we are up again"
  NOTIFY_ME -> "Notify me"
  ADDRESS -> "Address"
  CHANGE -> "Change"
  SAVE_AS -> "Save as"
  ADD_TAG -> "Add Tag"
  WORK -> "Work"
  OTHER -> "Other"
  SAVE -> "Save"
  ADD_NEW_ADDRESS -> "Add New Address"
  SAVED_ADDRESSES -> "Saved Addresses"
  ADDRESSES -> "Addresses"
  NO_FAVOURITES_SAVED_YET -> "No favourites saved yet"
  SAVED_ADDRESS_HELPS_YOU_KEEP_YOUR_FAVOURITE_PLACES_HANDY -> "Favourite location helps in keeping your frequently visited places handy"
  EMERGENCY_CONTACTS -> "Emergency Contacts"
  ADD_EMERGENCY_CONTACTS -> "Add Emergency Contacts"
  ADD_ANOTHER_CONTACT -> "Add Another Contact"
  NO_EMERGENCY_CONTACTS_SET -> "No Emergency Contacts Set"
  EMERGENCY_CONTACTS_SCREEN_DESCRIPTION -> "You can share your ride status in case of an emergency with upto 3 emergency contacts."
  COPIED -> "Copied"
  TRIP_ID -> "Trip Id"
  SAVE_PLACE -> "Save Place"
  RIDE_FARE -> "Ride fare"
  ASK_FOR_PRICE -> "Ask for a price"
  ASK_FOR_PRICE_INFO -> "You will receive a fare based on <b> government set </b> base price , with an additional <b> Rs.10 </b> nominal fee for the <b> pick-up distance </b> traveled by the drivers. Some drivers may request nominal tips solely at their discretion to cover factors like traffic, chances of return trip etc."
  GET_ESTIMATE_FARE -> "Get estimate fare"
  SELECT_AN_OFFER_FROM_OUR_DRIVERS -> "Select an offer (Optional)"
  SELECT_AN_OFFER_FROM_OUR_DRIVERS_INFO -> "By default, when “<b>Auto-assign a ride</b>” is enabled, you are assigned a driver who accepts the request first, within the estimate range. Instead, if you wish to choose a driver offer, you can disable and proceed."
  PAY_THE_DRIVER -> "Pay the driver"
  PAY_THE_DRIVER_INFO -> "Pay the driver directly, the price that was confirmed by you"
  PAY_THE_DRIVER_NOTE -> "(Total fare may change if ride distance changes)"
  UPDATE_PERSONAL_DETAILS -> "Update Personal Details"
  EDIT -> "Edit"
  DEL_ACCOUNT -> "Delete Account"
  ACCOUNT_DELETION_CONFIRMATION -> "Are you sure you want to delete your account? All your personal data will be lost"
  REQUEST_SUBMITTED -> "Request Submitted"
  WE_WILL_DELETE_YOUR_ACCOUNT -> "We are sorry to see you leave our platform. We will delete your account within the next 30 days. Should you want to retain your account, please do call us on our support number"
  YES_DELETE_IT -> "Yes, Delete It"
  REQUEST_TO_DELETE_ACCOUNT -> "Request To Delete Account"
  CANCEL_STR -> "Cancel"
  LOADING -> "Loading"
  PLEASE_WAIT_WHILE_IN_PROGRESS -> "Please wait while in progress"
  SET_LOCATION_ON_MAP -> "Set location on map"
  CURRENT_LOCATION -> "Current Location"
  I_AM_NOT_RECEIVING_ANY_RIDES -> "I am not receiving any rides"
  DELETE -> "Delete"
  ARE_YOU_SURE_YOU_WANT_TO_LOGOUT -> "Are you sure you want to logout ?"
  ARE_YOU_SURE_YOU_WANT_TO_CANCEL -> "Are you sure you want to Cancel ?"
  YOU_HAVE_RIDE_OFFERS_ARE_YOU_SURE_YOU_WANT_TO_CANCEL -> "You have ride offers, are you sure you want to cancel?"
  GO_BACK_ -> "Go Back"
  REGISTER_USING_DIFFERENT_NUMBER -> "Do you want to register using a different mobile number ?"
  YES -> "Yes"
  NO -> "No"
  CANCEL_ -> "Cancel"
  IS_ON_THE_WAY -> "is on the way.."
  ENTER_4_DIGIT_OTP -> "Enter 4 digit OTP"
  WRONG_OTP -> "Wrong OTP"
  GRANT_ACCESS -> "Grant Access"
  ENTER_A_LOCATION -> "Enter a location"
  NEARBY -> "Nearby"
  MINS_AWAY -> "mins Away"
  PAID -> "Paid"
  BY_CASH -> "by Cash"
  ONLINE_ -> "Online"
  USER -> "User"
  EMAIL_ALREADY_EXISTS -> "Failed to update email. Email already exists."
  IN -> "in"
  VERIFYING_OTP -> "Verifying OTP"
  TRACK_LIVE_LOCATION_USING -> "Track live location using"
  GOOGLE_MAP_ -> "Google Map"
  IN_APP_TRACKING -> "In app tracking"
  REQUEST_TIMED_OUT -> "Request Timed Out"
  LIMIT_EXCEEDED -> "Limit Exceeded"
  ERROR_OCCURED -> "Error Occured"
  QUOTE_EXPIRED -> "Quote Expired"
  GETTING_ESTIMATES_FOR_YOU -> "Getting estimates for you..."
  CONFIRM_PICKUP_LOCATION -> "Confirm Pickup Location"
  CONFIRM_DROP_LOCATION -> "Confirm Drop Location"
  NO_DRIVERS_AVAILABLE -> "No Drivers Available"
  ERROR_OCCURED_TRY_AGAIN -> "Error Occured. Try Again"
  ERROR_OCCURED_TRY_AFTER_SOMETIME -> "Error Occured. Please try again"
  ASKED_FOR_MORE_MONEY -> "Asked for more money"
  START_ -> "Start"
  LIMIT_REACHED -> "Limit Reached. Try after sometime"
  RIDE_NOT_SERVICEABLE -> "Ride Not Serviceable"
  CONFIRM_FOR -> "Confirm for"
  ETA_WAS_TOO_SHORT -> "ETA was too short."
  DRIVER_REQUESTED_TO_CANCEL -> "Driver requested me to cancel"
  PICK_UP_LOCATION_INCORRECT -> "The pickup location was incorrect."
  COULD_NOT_CONNECT_TO_DRIVER -> "I could not connect to driver."
  ETA_WAS_TOO_LONG -> "ETA was too long."
  OTHERS -> "Others"
  DESTINATION_OUTSIDE_LIMITS -> "Destination Entered is outside city limits"
  DROP_LOCATION_FAR_AWAY -> "Your drop Location is too far away"
  CHANGE_DROP_LOCATION -> "Change Drop Location"
  YOU_CAN_TAKE_A_WALK_OR_CONTINUE_WITH_RIDE_BOOKING -> "You may wish to walk or continue with the ride booking"
  YOUR_TRIP_IS_TOO_SHORT_YOU_ARE_JUST -> "Your trip distance is too short. Destination is just "
  METERS_AWAY_FROM_YOUR_DESTINATION -> "m away!"
  BOOK_RIDE_ -> "Book Ride"
  CANCEL_AUTO_ASSIGNING -> "Cancel Auto Assigning"
  LOCATION_UNSERVICEABLE -> "Location unserviceable"
  CURRENTLY_WE_ARE_LIVE_IN_ -> "Currently we're live in Bengaluru and Mysuru, you can enjoy our services there"
  CHANGE_LOCATION -> "Change Location"
  AUTO_ACCEPTING_SELECTED_RIDE -> "Auto accepting in"
  THE_TRIP_IS_VERY_SHORT_AND_JUST_TAKE -> "The trip is very short and just take"
  IF_YOU_STILL_WANNA_BOOK_RIDE_CLICK_CONTINUE_AND_START_BOOKING_THE_RIDE -> "if you still wanna book click continue and start booking the ride"
  STEPS_TO_COMPLETE -> "Steps to complete"
  HELP_US_WITH_YOUR_REASON -> "Help us with your reason"
  MAX_CHAR_LIMIT_REACHED -> "Max character limit reached,"
  DRIVER_WAS_NOT_REACHABLE -> "Driver wasn't reachable"
  SHOW_ALL_OPTIONS -> "Show all options"
  EXPIRES_IN -> "Expires in"
  PAY_DIRECTLY_TO_YOUR_DRIVER_USING_CASH_UPI -> "*Pay directly to your driver using Cash / UPI"
  UPDATE_REQUIRED -> "Update Required"
  PLEASE_UPDATE_APP_TO_CONTINUE_SERVICE -> "Please update app to continue service"
  NOT_NOW -> "Not now"
  OF -> "of"
  LOST_SOMETHING -> "Lost Something?"
  TRY_CONNECTING_WITH_THE_DRIVER -> "Try connecting with the driver"
  CALL_DRIVER -> "Call Driver"
  NO_MORE_RIDES -> "No more rides"
  CONTACT_SUPPORT -> "Contact Support"
  INVALID_MOBILE_NUMBER -> "Invalid mobile number"
  RIDE_COMPLETED -> "Ride Completed"
  SUBMIT_FEEDBACK -> "Submit Feedback"
  HOW_WAS_YOUR_RIDE_EXPERIENCE -> "How was your ride experience?"
  DROP -> "Drop"
  RATE_YOUR_RIDE_WITH -> "Rate your ride with "
  VIEW_BREAKDOWN -> "View Breakdown"
  PAY_DRIVER_USING_CASH_OR_UPI -> "Pay Driver using Cash/UPI"
  RATE_YOUR_DRIVER -> "Rate Your Driver"
  MY_RIDES -> "My Rides"
  RIDE_DETAILS -> "Ride Details"
  RIDE_ID -> "Ride ID"
  SELECT_A_RIDE -> "Select a ride for more details"
  CONFIRM_RIDE_ -> "Confirm Ride"
  YOU_CAN_CANCEL_RIDE -> "You can cancel once you get offer from drivers"
  ESTIMATES_CHANGED -> "The estimate for your ride has changed now"
  ESTIMATES_REVISED_TO -> "The revised estimate is"
  RATE_CARD -> "Rate Card"
  NIGHT_TIME_CHARGES -> "Night-time Charges"
  MIN_FARE_UPTO -> "Min. Fare upto 2 km"
  RATE_ABOVE_MIN_FARE -> "Rate above Min. Fare"
  DRIVER_PICKUP_CHARGES -> "Driver Pickup Charges"
  NOMINAL_FARE -> "Nominal Fare*"
  DAY_TIMES_OF -> ""
  DAYTIME_CHARGES_APPLICABLE_AT_NIGHT -> "x of daytime charges applicable at night from 10 PM to 5 AM"
  NIGHT_TIMES_OF -> ""
  DAYTIME_CHARGES_APPLIED_AT_NIGHT -> "x of daytime charges applied to fare at night (🌙) from 10 PM to 5 AM"
  DRIVERS_MAY_QUOTE_EXTRA_TO_COVER_FOR_TRAFFIC -> "* Driver may quote extra to cover for traffic, chance of return trip etc."
  GOT_IT -> "Got It!"
  DAY_TIME_CHARGES -> "Daytime Charges"
  SHARE_APP -> "Share App"
  AWAY_C -> "Away"
  AWAY -> "away"
  AT_PICKUP -> "At Pickup"
  FARE_UPDATED -> "Fare updated"
  TOTAL_FARE_MAY_CHANGE_DUE_TO_CHANGE_IN_ROUTE -> "Total fare may change due to change in route"
  AT_DROP -> "At Drop"
  EMERGENCY_HELP -> "Emergency Help"
  CALL_POLICE -> "Call Police"
  ALSO_SHARE_YOUR_RIDE_STATUS_AND_LOCATION -> "Also shares your ride status and location"
  SHARE_RIDE_WITH_EMERGENCY_CONTACTS -> "Share Ride with Emergency Contacts"
  DO_YOU_NEED_EMERGENCY_HELP -> "Do you need Emergency Help ?"
  CALL_SUPPORT -> "Call Support"
  YOU_ARE_ABOUT_TO_CALL_NAMMA_YATRI_SUPPORT -> "You are about to place a call to the Namma Yatri Support Team. Do you want to proceed?"
  YOU_ARE_ABOUT_TO_CALL_POLICE -> "You are about to place a call to the Police. Do you want to proceed?"
  DAIL_100 -> "Dial 100?"
  HELP_US_WITH_YOUR_FEEDBACK -> "Help us with your feedback"
  WAIT_TIME -> "Wait Time"
  FAVOURITES -> "Favourites"
  ADD_FAVOURITE -> "Add Favourite"
  ALL_FAVOURITES -> "All Favourites"
  REMOVE -> "Remove"
  CONFIRM_LOCATION -> "Confirm Location"
  SELECT_ON_MAP -> "Select on map"
  FAVOURITE_LOCATION -> "Favourite Location"
  EDIT_FAVOURITE -> "Edit favourite"
  DRAG_THE_MAP -> "Drag the map & set pin to exact location" 
  CHOOSE_ON_MAP -> "Choose on map"
  USE_CURRENT_LOCATION -> "Use current location"
  FAVOURITE_YOUR_CURRENT_LOCATION -> "Favourite your current location"
  LOCATION -> "Location"
  LOCATION_ALREADY_EXISTS_AS -> "Location already exists as"
  GIVE_THIS_LOCATION_A_NAME -> "Give this location a name"
  FAVOURITE -> "Favourite"
  CONFIRM_AND_SAVE -> "Confirm & Save"
  REMOVE_FAVOURITE -> "Remove Favourite"
  ARE_YOU_SURE_YOU_WANT_TO_REMOVE_FAVOURITE_ -> "Are you sure you want to remove a \n favourite location?"
  YES_REMOVE -> "Yes, Remove"
  ADD_NEW_FAVOURITE -> "Add New Favourite"
  SELECT_YOUR_DROP -> "Select your drop"
  FAVOURITE_REMOVED_SUCCESSFULLY -> "Favourite Removed Successfully"
  LOCATION_ALREADY_EXISTS -> "location already exists"
  FAVOURITE_LIMIT_REACHED -> "Favourite limit reached"
  LOCATION_ALREADY -> "Location already"
  EXISTS_AS -> "exists as"
  FAVOURITE_ADDED_SUCCESSFULLY -> "Favourite Added Successfully"
  FAVOURITE_UPDATED_SUCCESSFULLY -> "Favourite Updated Successfully"
  ALREADY_EXISTS -> "Already Exists"
  NAME_ALREADY_IN_USE -> "Name already in-use"
  SELECT_FAVOURITE -> "Select Favourite"
  CONFIRM_CHANGES -> "Confirm Changes"
  ADD_SAVED_LOCATION_FROM_SETTINGS -> "*You can add new favourites from Side menu > Favourites"
  YOU_WILL_BE_ASKED_TO_SELECT_CONTACTS -> "You will be asked to select upto 3  contacts"
  AUTO_ASSIGN_A_RIDE -> "Auto-assign a ride"
  IS_WAITING_FOR_YOU -> "is waiting for you..."
  WAIT_TIME_TOO_LONG -> "Wait time too long"
  GOT_ANOTHER_RIDE_ELSE_WHERE -> "Got another ride elsewhere"
  DRIVER_WAS_RUDE -> "Driver was rude"
  MAYBE_LATER -> "Maybe Later"
  YOUR_RIDE_HAS_STARTED -> "Yay! Your ride has started 🤩"
  ENJOY_RIDING_WITH_US -> "Enjoying riding with us? Spread the \n word and share the cheer"
  VIEW_DETAILS -> "View Details"
  REPEAT_RIDE -> "Repeat Ride"
  FARE_WAS_HIGH -> "Fare was high"
  AUTO_ASSIGN_DRIVER -> "Auto-assign a driver"
  CHOOSE_BETWEEN_MULTIPLE_DRIVERS -> "Choose between multiple drivers"
  CHOOSE_BETWEEN_MULTIPLE_RIDES -> "Choose between multiple ride options"
  ENABLE_THIS_FEATURE_TO_CHOOSE_YOUR_RIDE -> "Enable this feature to choose your preferred ride & fare"
  BOOKING_PREFERENCE -> "Booking Preference"
  BASE_FARES -> "Base Fare "
  PICKUP_CHARGE -> "Driver Pickup Charges"
  TOTAL_PAID -> "Total Paid"
  WAITING_CHARGE -> "Waiting Charges**"
  NOMINAL_FARES -> "Nominal Fare*"
  DRIVERS_CAN_CHARGE_AN_ADDITIONAL_FARE_UPTO -> "* Drivers can charge an additional fare upto ₹20 to cover other factors like traffic, chances of return trip etc."
  WAITING_CHARGE_DESCRIPTION -> "** Waiting charges : ₹1 / min - after 3 mins of drivers arrival"
  SUCCESSFUL_ONBOARD -> "You have successfully signed on to \nNamma Yatri"
  HAVE_REFERRAL_CODE -> "Have a Referral Code?"
  REFEREAL_CODE_DISCRIPTION -> "Your referral might just be the reason for \n a driver to be rewarded!"
  SIX_DIGIT_REFERRAL_CODE -> "Enter 6 digit code shared by driver"
  ABOUT_REFERRAL_PROGRAM -> "What is the Referral Program?"
  ABOUT_REFERRAL_PROGRAM_DISCRIPTION -> "The referral program incentivises drivers to accept more rides, cancel less and serve you better by recognising and rewarding worthy drivers. \n\n You can help out by entering the driver’s referral code  and improve the quality of rides for the Namma Yatri Community!"
  YOU_CAN_GET_REFERRAL_CODE_FROM_DRIVER -> "\nYou can get a referral code by asking your Namma Yatri Driver."
  REFERRAL_CODE_SUCCESSFULL -> "You have successfully applied \nthe referral code!"
  REFERRAL_CODE_APPLIED -> "Referral Applied!"
  HEY -> "Hey"
  INVALID_CODE_PLEASE_RE_ENTER -> "Invalid Code. Please Re-enter"
  LET_TRY_THAT_AGAIN -> "Let's try that again..."
  CONTACTS_SELECTED -> "Contacts Selected"
  SELECT_CONTACTS -> "Select Contacts"
  CONFIRM_EMERGENCY_CONTACTS -> "Confirm Emergency Contacts"
  MAXIMUM_CONTACTS_LIMIT_REACHED -> "Maximum contacts limit reached"
  ARE_YOU_SURE_YOU_WANT_TO_REMOVE_CONTACT -> "Are you sure you want to remove them from your emergency contacts?"
  SEARCH_CONTACTS -> "Search Contacts"
  SELECTED_CONTACT_IS_INVALID -> "The selected contact is invalid. Please recheck the number and try again"
  CALL_EMERGENCY_CONTACTS -> "Call Emergency Contacts"
  LIVE_STATS_DASHBOARD -> "Live Stats Dashboard"
  CHECK_OUT_LIVE_STATS -> "Check out live stats"
  EMERGENCY_CONTACS_ADDED_SUCCESSFULLY -> "Emergency Contacts Added Successfully"
  NO_CONTACTS_FOUND_ON_DEVICE_TO_ADD -> "No contacts found on device to add"
  NO_CONTACTS_LEFT_ON_DEVICE_TO_ADD -> "No contacts left on device to add"
  PERMISSION_DENIED -> "Permission Denied"