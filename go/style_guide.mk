## Style Guide

Disclaimer: We acknowledge that this style guide is highly opiniated as any other style guide but the main goal is to create the most suitable rules for all. And make code as consistent as its possible.


#### 1. Line length

Hard limit at the moment of writing this guide is 180 symbols because of very late introduction of line lenght restriction to the project. Soft limit which is a goal of all new code is 100 symbols with some rare exceptions. 80 symbols per line is not mandatory but still preferable, this stays up to developer to decide whether to stick to it or not.
100 symbols is decided because its maximum line which is still visible on average editor on average 13'' laptop in two-pane mode.

Exceptions are left to decide whether to use them and when to use them up to developers, because they are so rare and unique. But its better to think twice whether You really need that long line or it can be avoided.


#### 2. Comments

Write all comments required by used linters - all exported items should be commented.
Avoid obvious comments at all costs, e.g. "doing update", "sending request" etc.
Comment only obscured parts of logic - business logic dependant parts, optimisations, non-obvious calculations.
If You feel that You need to write comment to explain whats happening in some part of Your code, first try to simplify and decompose that part and use comments only if they are completely necessary.
Comments should explain WHY instead of WHAT.
Proper variable/function names often better explain whats going on than comments.
If You use comments to separate one logical part of function from another, better to split this function in two separate ones with proper names.


#### 3. Import order

All imported items should be divided into three sections, separated by empty lines each.
First goes standart library imports, then external imports and then internal ones. Alphabetical order should be preserved, but usually `goimports` takes care about that.


#### 4. Variables

##### 4.1 Naming

Use short and convenient names for variables.
Be consistent with variable names, i.e. if use abbreviation - stick to it in all other places. E.g. `req` and `request` are both valid names, but do not mix them.
Avoid repeated and self-explanatory names and always consider context where variable is used, i.e.
```go
contracts, err := s.storage.GetUserBrokerContracts(ctx, userID.Id)
// instead of
brokerContracts, err := s.storage.GetUserBrokerContracts(ctx, userID.Id)
```

```go
brokerClient, err := NewClient(target)
// instead of
brokerServiceClient, err := NewClient(target)
// or even just
client, err := NewClient(target)
// if its the only client within given scope
```

Use extremely short names and abbreviations only if its 100% clear whats going on
```go
// parameters are immediately passed to new structure so their names are less important than types
func NewImporter(
	fsc filepb.FileServiceClient,
	tmsc transmailpb.TransMailServiceClient,
	bsc brokerpb.BrokerServiceClient,
) *Importer {
	return &Importer{
		fileClient: fsc,
		transMailClient: tmsc,
		brokerClient: bsc,
	}
}
```

but NOT
```go
bsc, err := NewClient(target)
...
// couples lines below client creation, its completely unclear what bcs actually is
resp, err := bcs.UpdateProfile(ctx, req)
```

##### 4.2 Definition

Use constants for values only if they used more than once.
Export and/or move constants to separate file/module if they shared between packages.
Use type guessing syntax (`:=`) for variables whenever its possible.
Use `var` syntax for variable definition only if variables defined outside functions or You intentially want to show that they aren't initialized.
Use `const` syntax withing function only if its 100% necessary to show that variables should be unchanged withing function scope.

##### 4.3 Struct initialization

Always use explicit field names for struct initialization
```go
response := &brokercontractpb.BrokerContractIDMessage{
	Id:			updatedContract.Id,
	ExternalId:	updatedContract.ExternalId,
}
// instead of
response := &brokercontractpb.BrokerContractIDMessage{
	updatedContract.Id,
	updatedContract.ExternalId,
}
```

Second one may be shorter but much-much harder to understand without knowing actual structure definition

Always put each structure field on separate line.
Exception may be well known structure from standart library which is used within other structure.
```go
x := &xogarden.AppVersion{
	UserID:		sql.NullString{String: r.UserId, Valid: r.UserId != ""},
	Platform:	int(r.Platform),
	Version:	r.Version,
	CreatedAt:	&now,
}
```

But again, preferable way is to put each field on separate line.


#### 5. Functions

##### 5.1 Naming

All suggestion from variable naming are applied to functions.

Always consider package context in function names. I.e. if there is `time` package, no need to name parsing function `ParseTime`, just `Parse` can be used since it will be clear whats parsed from package name.

Go's standart library is great example of naming in general.

##### 5.2 Function definition

If code uses any kinds of brackects, always put bracket contents on new line and closing bracket on new line too, e.g.

```go
func (s *Service) sendNewInsuranceEmail(
	ctx context.Context, req *userpb.User, bc *brokercontractpb.BrokerContract,
) error {
	....
}
```

instead of
```go
func (s *Service) sendNewInsuranceEmail(ctx context.Context, req *userpb.User,
	bc *brokercontractpb.BrokerContract) error {
	....
}
```

If function parameters do not fit in one line - put each parameter on separate line.
One exception - parameters with same type can be one the same line, if type is mentioned only once.

```go
func (s *Service) getStaticMapping(
	w http.ResponseWriter,
	req *http.Request,
	pathParams map[string]string,
	version int32,
) {
	...
}
```

```go
func createBrokerContractAttributes(
	status brokercontractpb.BrokercontractStatus,
	activatedAt, validUntil, netPrice, grossPrice, taxRate, paymentPeriod string,
) {
	...
}
```

or
```go
func createBrokerContractAttributes(
	status brokercontractpb.BrokercontractStatus,
	activatedAt string,
	validUntil string,
	netPrice string,
	grossPrice string,
	taxRate string,
	paymentPeriod string,
) {
	...
}
```

but NOT
```go
func createBrokerContractDocuments(
	externalID string, insuranceInquiry *xofondsfinanz.InsuranceInquiry,
	insuranceDocuments []*xofondsfinanz.InsuranceDocument,
) []*brokercontractpb.BrokerContractDocument {
	...
}
```

##### 5.3 Function call

If function call needs to be split, always put parameters on new line.
```go
updatedContract, updatedMsgs := updateContract(
	dbContract, historyContractRecord, req,
)
```

and NOT
```go
updatedContract, updatedMsgs := updateContract(dbContract,
	historyContractRecord, req,)
```

And do not leave closing bracket hanging

```go
// NOT
updatedContract, updatedMsgs := updateContract(
	dbContract, historyContractRecord, req)
```

If parameters do not fit in one line, put each parameter on separate line
```go
_status, _rejectionReason := status(
	importRow.FfStatusRejected,
	importRow.FfStatusPolicyTransferRejection,
	importRow.FfStatusRequested,
	importRow.FfStatusPolicyTransferAcception,
	importRow.FfStatusPolicified,
	importRow.FfStatusAccepted,
	importRow.FfStatusPolicyTransferForeignDa,
)
```

Instead of
```go
_status, _rejectionReason := status(
	importRow.FfStatusRejected, importRow.FfStatusPolicyTransferRejection, importRow.FfStatusRequested,
	importRow.FfStatusPolicyTransferAcception,
	importRow.FfStatusPolicified, importRow.FfStatusAccepted, importRow.FfStatusPolicyTransferForeignDa,
)
```

Only exception is if parameters passed by pairs or with some other logical grouping
```go
sisulog.Error(
	ctx,
	"ForceUpsertBrokerContract s.storeUpdatedContract",
	"error", err, "contract", req,
)
```


#### 6. Flow Control statements

Use short check syntax if line is within given limit and result of check is not used
```go
if _, err := checkResult(res); err != nil {
	...
}
```

but
```go
err = s.NotifyUsersOfActivatedContracts(
	ctx, []*brokercontractpb.BrokerContract{updatedContract},
)
if err != nil {
	sisulog.Error(ctx, "Error while executing NotifyUsersOfActivatedContracts")
}

// instead of
if err = s.NotifyUsersOfActivatedContracts(ctx, []*brokercontractpb.BrokerContract{updatedContract}); err != nil {
	sisulog.Error(ctx, "Error while executing NotifyUsersOfActivatedContracts")
}
```

Same applies to boolean expressions
Put each expression on separate line
```go
if sJob.NumberRecordsProcessed > 0 &&
	sJob.NumberRecordsProcessed == sJob.NumberRecordsFailed {
	...
}
// instead of
if sJob.NumberRecordsProcessed > 0 && sJob.NumberRecordsProcessed == sJob.NumberRecordsFailed {
	...
}
```

Sometimes its even better to put result of each individual expression to separate variable to improve readability
```go
forceStatusChanged := record.RecordChangedField == crmobjects.ForceStatus
readyToTransfer := record.RecordNewValue == crmobjects.InsuranceDraftStatusREADYTOTRANSFER.String()
if forceStatusChanged && readyToTransfer {
	...
}
// instead of
if record.RecordChangedField == crmobjects.ForceStatus && record.RecordNewValue == crmobjects.InsuranceDraftStatusREADYTOTRANSFER.String() {
	...
}
```

Follow rule of "early exit", i.e. check for cases, which cause return or errors as early as possible.
This reduces nesting and makes code easier to read and restructure if needed.
For example
```go
if ValidateRequest(request) {
	req := messagepb.Request{
		Id: request.MessageID,
		Body: request.MessageBody,
	}
	resp, err := s.messages.Send(ctx, &req)
	if err != nil {
		return nil, err
	}
	// etc
	return resp, nil
}

return nil, errors.New("not valid request")

// much better
if !ValidateRequest(request) {
	return nil, errors.New("not valid request")
}

req := messagepb.Request{
	Id: request.MessageID,
	Body: request.MessageBody,
}
resp, err := s.messages.Send(ctx, &req)
if err != nil {
	return nil, err
}
// etc
return resp, nil
```

Avoid using labeled loop breaks, e.g.
```go
label:
for _, user := range users {
	userTotal := 0
	for _, contract := range user.Contracts {
		if contract.IsFree {
			continue label
		}
		userTotal += contract.Price
	}
	totalSum += userTotal
}
```

First try to get rid of nested loop at all, if this is unavoidable, and You need to break from it - move it to separate function. E.g.
```go
contractsTotalSum := func(contracts []Contract) int64 {
	total := 0
	for _, contract := range contracts {
		if contract.IsFree {
			return 0
		}
		total += contract.Price
	}
	return total
}

for _, user := range users {
	totalSum += contractsTotalSum(user.Contracts)
}
```


#### 7. Logging

Logging is a powerful instrument which helps with debugging and error handling, but it should be used wisely.
All logging should be done on the same abstraction level - whether You're using rest or grps technology, log errors only in etry/exit points, which are handlers.
If You're writing library, logger should be passed/set externally using some common interface and all logging should be done in exported library functions/methods.
This means that in all other places You just return errors.

Always add to log messages information, which then will help You or someone else to identify cause of error. If its some entity, always add id, if its validation error, add information which was validated.
But keep in mind size of payload added to log messages - don't add whole files or whole request, if it may contain hundreds or even thousands of records inside it.

Be consistent with style of log messages, if its library or service, add its name as prefix.
Be short and precise with messages, same rules apply as with commenting.
E.g.
```go
logger.Debug("Handling update request...")
// but better
logger.Debugf("[User] Update | Request: %s", request)
```


#### 8. Error handling




#### 9. Packages, modules

#### 10. DRY, KISS?

#### 11. Service/project specifics

##### 11.1 Structure

##### 11.2 inMemory or dummy for client and storage?

##### 11.3 Testing
