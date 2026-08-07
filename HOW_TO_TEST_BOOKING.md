# How to Test Booking Submission

## Quick Test Steps

1. **Connect your Samsung A54 via USB cable** (most reliable)
   - Enable USB Debugging on your phone
   - Connect the USB cable
   - Accept the debugging prompt on your phone

2. **Run the app from your computer**
   ```bash
   flutter run
   ```

3. **Test the booking submission**
   - Navigate to the booking form
   - Fill in all required fields
   - Try to submit a booking

4. **Check the console output**
   Look for these emoji-tagged messages:
   ```
   📝 BookingService: Starting createBooking...
   ✅ BookingService: User authenticated: [user-id]
   📄 BookingService: Created document reference: [doc-id]
   🖼️ BookingService: Has images: true/false
   💾 BookingService: Writing main booking document...
   ```

5. **If it fails, you'll see:**
   ```
   ❌ BookingService: Error creating booking: [ERROR MESSAGE]
   📚 BookingService: Stack trace: [STACK TRACE]
   ```

6. **Share the error with me**
   - Copy the entire error message from the console
   - Share it with me so I can help fix it

## Alternative: Test Without USB

If you can't connect via USB, you can:

1. **Build and install the APK**
   ```bash
   flutter build apk --debug
   ```

2. **Install it on your phone**
   - The APK will be in: `build/app/outputs/flutter-apk/app-debug.apk`
   - Transfer it to your phone and install it

3. **Use Android Studio's Logcat**
   - Open Android Studio
   - Go to View → Tool Windows → Logcat
   - Filter by "BookingService" or "flutter"
   - Try to submit a booking
   - Look for the emoji-tagged log messages

## What to Look For

The most common errors will be:

### 1. Permission Denied
```
❌ BookingService: Error creating booking: [firebase_firestore/permission-denied]
```
**Fix**: Update Firestore security rules (see FIRESTORE_IMPLEMENTATION_CHECKLIST.md)

### 2. Network Error
```
❌ BookingService: Error creating booking: [firebase_firestore/unavailable]
```
**Fix**: Check internet connection

### 3. User Not Authenticated
```
❌ BookingService: User not logged in
```
**Fix**: Make sure user is signed in before accessing booking form

## Need Help?

Share the console output with me and I'll help you fix the specific issue!
