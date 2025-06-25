# Community Solar Subscription Management – Solution & Explanation

### 🧩 Take away problem:

When customers sign-up for community solar, they subscribe to one or more Shared Solar Systems via Subscriptions. A Subscription can’t exist without a customer, and it must always be linked to a Shared Solar System.

- A customer can have multiple Subscriptions to multiple Shared Solar Systems.  
**How would you model this relationship?**

- Subscriptions should not have overlapping effectivity dates for the same Shared Solar System.  
**How would you ensure this doesn’t happen?**

- **How would you track effectivity dates and statuses?**  
**How would you update the Shared Solar System with the currently effective Subscriptions?**

---

## ✅ Solution:

1. Three main entities are mentioned, namely –  
- Customer  
- Subscription  
- Shared Solar System

It’s also mentioned that –  
- Customer can subscribe to one or more Shared Solar Systems.  
- Subscription must have a Customer.  
- Subscription must always be linked to a Shared Solar System.  
- Customer can have multiple Subscriptions to multiple Shared Solar Systems.

This represents a **many-to-many relationship**, and in Salesforce, it can be achieved using a **Junction object**.

Hence, the data model below would represent the mentioned relationship:

<img width="459" alt="image" src="https://github.com/user-attachments/assets/2e0e88db-2147-444e-95e7-06b407b065c6" />


### ⚙️ A few pointers about this data model:

- `Customer` Object represents Master - 1.  
- `Shared Solar System` Object represents Master - 2.  
- `Subscription` Object represents the Junction Object.  
- (Customer–Subscription) is a Master-Detail relationship (Master-detail 1).  
- (Shared Solar System–Subscription) is a Master-Detail relationship (Master-detail 2).  
- `Subscription` Object has 2 parent objects – Customer and Shared Solar System.

---

  ## 2.	Subscriptions should not have overlapping effectivity dates for the same Shared Solar System.

We will have two fields on each Subscription:  
- `Start_Date__c`  
- `End_Date__c`

**Overlapping Logic:**  
If there are two subscriptions:

- Sub1: Start_Date_1 and End_Date_1
- Sub2: Start_Date_2 and End_Date_2

Then Sub2 overlaps Sub1 if:
(Start_Date_2 <= End_Date_1 && End_Date_2 >= Start_Date_1)


### 🧾 Example Data:

| S.No | Customer | Subscription | Shared Solar System |
|------|----------|--------------|---------------------|
| 1    | C1       | Sub1         | Ss1                 |
| 2    | C2       | Sub2         | Ss1                 |
| 3    | C1       | Sub3         | Ss2                 |
| 4    | C1       | Sub4         | Ss1                 |
| 5    | C2       | Sub5         | Ss1                 |
| 6    | C2       | Sub6         | Ss2                 |

- Record 4 overlaps with 1  
- Record 5 overlaps with 2  
- Record 6 doesn’t overlap

---

## 🔄 Implementation in Salesforce (Trigger)

### ✅ Prevent Overlapping Subscriptions

**Trigger Context:** `before insert` and `before update`

#### Algorithm:
1. If insert or `Start_Date__c` / `End_Date__c` changed
2. Group new records by `Customer__c + '_' + Shared_Solar_System__c`
3. Query existing subscriptions with same `Customer` & `Solar System`
4. For each new subscription, check against existing using: 
### 🧾 Example Data:

| S.No | Customer | Subscription | Shared Solar System |
|------|----------|--------------|---------------------|
| 1    | C1       | Sub1         | Ss1                 |
| 2    | C2       | Sub2         | Ss1                 |
| 3    | C1       | Sub3         | Ss2                 |
| 4    | C1       | Sub4         | Ss1                 |
| 5    | C2       | Sub5         | Ss1                 |
| 6    | C2       | Sub6         | Ss2                 |

- Record 4 overlaps with 1  
- Record 5 overlaps with 2  
- Record 6 doesn’t overlap

---

## 🔄 Implementation in Salesforce (Trigger)

### ✅ Prevent Overlapping Subscriptions

**Trigger Context:** `before insert` and `before update`

#### Algorithm:
1. If insert or `Start_Date__c` / `End_Date__c` changed
2. Group new records by `Customer__c + '_' + Shared_Solar_System__c`
3. Query existing subscriptions with same `Customer` & `Solar System`
4. For each new subscription, check against existing using: 
### 🧾 Example Data:

| S.No | Customer | Subscription | Shared Solar System |
|------|----------|--------------|---------------------|
| 1    | C1       | Sub1         | Ss1                 |
| 2    | C2       | Sub2         | Ss1                 |
| 3    | C1       | Sub3         | Ss2                 |
| 4    | C1       | Sub4         | Ss1                 |
| 5    | C2       | Sub5         | Ss1                 |
| 6    | C2       | Sub6         | Ss2                 |

- Record 4 overlaps with 1  
- Record 5 overlaps with 2  
- Record 6 doesn’t overlap

---

## 🔄 Implementation in Salesforce (Trigger)

### ✅ Prevent Overlapping Subscriptions

**Trigger Context:** `before insert` and `before update`

#### Algorithm:
1. If insert or `Start_Date__c` / `End_Date__c` changed
2. Group new records by `Customer__c + '_' + Shared_Solar_System__c`
3. Query existing subscriptions with same `Customer` & `Solar System` and for update exclude current records
4. For each new subscription, check against all existing subscriptions of the same customer & solar system using: `newStart <= existingEnd && newEnd >= existingStart`
5. 5. If overlap, throw error

## Trigger Framework Files

I’ve implemented and coded the solution in the 3 attached files, which are part of a trigger framework:

### • restrictOverlappingSubscriptions.trigger
- Ensures no logic is written directly inside the trigger.  
- Delegates all logic to a centralized handler class based segregated by context, i.e., beforeInsert or beforeUpdate.

### • SubscriptionTriggerHandler.cls
- Organizes logic based on trigger context: before insert, before update, etc.  
- Each method calls the utility method `processOverlappingCheck()` to check the overlapping Subscriptions.

### • SubscriptionTriggerHandlerUtil.cls
- Contains reusable methods such as `processOverlappingCheck()` - for validating overlapping subscriptions.

---
## 3. How would you track effectivity dates and statuses? How would you update the Shared Solar System with the currently effective Subscriptions?

To track the effectivity dates and statuses, let’s consider the possible statuses of any Subscription as either Active or Inactive.

**Criteria:**  
If `(today >= sub.Start_Date__c && today <= sub.End_Date__c)` then Subscription should be **Active**  
Else, the Subscription should be **Inactive**.

### Scenarios:
1. A new subscription is added, and we want to update the status using the above criteria.  
2. There are existing subscriptions in the system, and we want to update their statuses from time to time, as today’s date will be changing with each passing day.

---
### For Scenario 1: A new subscription is added, and we want to update the status using the above criteria:

The above solution can be implemented in Salesforce using a trigger with below algorithm –

### Automatically Set Status on Subscription (Trigger)
1. Trigger Context: Run in `before insert` and `before update`.
2. Conditionally Update `Status__c`:  
   - If `Start_Date__c` or `End_Date__c` changed, or it's a new record:  
     ```apex
     if (today >= sub.Start_Date__c && today <= sub.End_Date__c)
       → Status = 'Active'
     else
       → Status = 'Inactive'
     ```

I’ve incorporated the changes for this in the existing trigger framework that I implemented as part of the solution for problem 2.

### • restrictOverlappingSubscriptions.trigger
- Ensures no logic is written directly inside the trigger.  
- Delegates all logic to a centralized handler class based segregated by context, i.e., beforeInsert or beforeUpdate.

### • SubscriptionTriggerHandler.cls
- Organizes logic based on trigger context: before insert, before update, etc.  
- Each method calls the utility method `updateSubscriptionStatus()` to update the statuses on the subscriptions

### • SubscriptionTriggerHandlerUtil.cls
- Contains reusable methods such as `updateSubscriptionStatus()` - for updating the statuses on the subscriptions on insert or update (if start date or end date is changed).

---

---

### 🧪 Unit Testing

Unit testing of `restrictOverlappingSubscriptions.cls`, `SubscriptionTriggerHandler.cls`, `SubscriptionTriggerHandlerUtil.cls` is implemented and coded in:  
- `Test_SubscriptionTriggerHandler.cls`

---

## ✅ Alternative Solution

The solution for this particular scenario can also be implemented using a **record trigger flow (before save)** using the same algorithm. Since it’s executed before the Apex before trigger in the order of execution, it can be much more efficient.

---

## 🔎 Few Considerations

- It’s a good idea to make sure that the **start date** and the **end date** of a subscription can’t be null, and the **start date is less than the end date**, using a **validation rule**.  
  This will be useful in eliminating defensive checks for the same in the code.

---

## For Scenario 2: Update statuses of existing Subscriptions daily

- Since we need to update the existing Subscriptions in the system with the status as either Active or Inactive, and the count of existing Subscriptions could be huge (which may exceed Salesforce governor limits), the recommended approach is to use **Batch Apex**.

- Since we have to update the statuses daily, it’s recommended that we **schedule this batch apex** to run every day at some particular time, for example, **12 AM**.  
  Hence, we also have to use **Schedule Apex**.

- We also have to **schedule the class using the Apex Scheduler from the Setup UI**.

---

### 🔁 Algorithm: Update Subscription Status via Batch Scheduler

1. **Scheduling**
   - Method `execute(SchedulableContext sc)` is invoked on schedule.
   - Triggers execution of the batch class with a batch size of 200 records.

2. **Start Method**
   - Query all `Subscription__c` records with `Id`, `Start_Date__c`, `End_Date__c`, and `Status__c`.
   - Return records to be processed in batches.

3. **Batch Execution (execute)**
   - For each record in the current batch (scope):  
     - Determine the expected status based on today’s date:  
       - Active if `(today >= sub.Start_Date__c && today <= sub.End_Date__c)`  
       - Otherwise, Inactive  
     - If current `Status__c` is different from expected:  
       - Update `Status__c` and collect for update

4. **Perform Update**
   - Use `Database.update()` with `allOrNone = false` to attempt update of all modified subscriptions.
   - Track any failed updates:
     - Capture failure reason and stack trace
     - Log to custom object `App_Log__c` with timestamp and related subscription

5. **Finish Method**
   - Insert all `App_Log__c` records that recorded failures, if any.

**Additional Notes:**
- Implements `Database.Stateful` to retain failed logs between batch chunks.

**Implemented in file:**  
- `UpdateSubscriptionStatusBatchScheduler.cls`

**Scheduling:**  
This can be scheduled from the UI with configurations like below.

---
![image](https://github.com/user-attachments/assets/ad451e65-4aab-4bcf-84cc-c17df1722e11)

---

### 🧪 Unit Testing

Unit testing of `UpdateSubscriptionStatusBatchScheduler.cls` is implemented and coded in:  
- `Test_UpdateSubscriptionStatusBatchScheduler.cls`

---

## 📌 How would you update the Shared Solar System with the currently effective Subscriptions?

### Possible Solutions:

**(A)** If we want to keep track of **count of active Subscriptions** on any Shared Solar System:
- Create a **Roll-Up Summary Field** on the Shared Solar System

**Configuration:**
- Master object: Shared Solar System  
- Summarized object: Subscription  
- Roll-Up Type: Count  
- Filter Criteria: Only records meeting certain criteria:

| Field  | Operator | Value  |
|--------|----------|--------|
| Status | equals   | Active |

---

**(B)** If we want to keep track of the **IDs of effective subscriptions**:
- Create a new field `Currently_Active_Subscriptions__c` (Text Area or Long Text) on the Shared Solar System.
- Implement and run a **batch daily** to update the IDs (concatenated by `,` or similar).

---

**(C)** To **query effective subscriptions** related to a Shared Solar System:

```
SELECT Id, Name 
FROM Subscription__c 
WHERE Shared_Solar_System__c = :solarSystemId 
AND Status__c = 'Active'
```
#### Note: We can rely on the Status__c field because it’s maintained both on insert/update and via the daily batch.
---

### (D) To display active subscriptions on the UI:

1. Go to the **Lightning Record Page** of **Shared Solar System** and click on **Edit**  
2. Add **Dynamic Related List** from the left panel into the main section  
3. Select object: **Subscriptions**  
4. Set filter:

| Field  | Operator | Value  |
|--------|----------|--------|
| Status | equals   | Active |

5. Click **Save**

#### A dynamic related list will now be present on the UI of the **Shared Solar Panel** record page showing only **Active Subscriptions**.
---
## 📁 Structure
- `/classes`: Apex classes and test classes
- `/triggers`: Trigger to restrict overlapping subscriptions

## ✅ Test Coverage
Includes unit tests for:
- `SubscriptionTriggerHandler`
- `UpdateSubscriptionStatusBatchScheduler`
- Overlapping subscription logic
