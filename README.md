# README
- Ruby 3.0.2

# run tests
- ensure the docker container is running `docker-compose up -d`
- then you can run `docker-compose exec web bundle exec rspec` in your terminal to run the tests via the docker container

# JSON Schema 2020-12
## ValidationSchema
- ValidationSchema model is the main parent model that builds the schema
- It has_many schema_property_fields
- The `all_of` attribute has been setup as a jsonb column and is serialized via `SchemaSerializer::AllOfDetails`
```
validation_schema = ValidationSchema.create(name: "new_user", title: "New User Signup", description: "Validation schema for signing up new users")

SchemaPropertyFieldString.new(name: "firstName", title: "First Name")
validation_schema.schema_property_fields = [
  SchemaPropertyFieldString.new(name: "firstName", title: "First Name", required: true),
  SchemaPropertyFieldString.new(name: "lastName", title: "Last Name", required: true),
  SchemaPropertyFieldString.new(name: "email", title: "Email", required: true)
]

validation_schema.to_schema_property
>>>
{
  "title"       => "New User Signup",
  "description" => "Validation schema for signing up new users",
  "properties" => {
    "firstName" => {
      "title"       => "First Name",
      "type"        => "string",
    },
    "lastName" => {
      "title"       => "Last Name",
      "type"        => "string",
    },
    "email" => {
      "title"       => "Email",
      "type"        => "string",
    }
  },
  "required" => ["firstName", "lastName", "email"]
}
```

### SchemaSerializer::AllOfDetails
- Takes one required param `properties`, which is an Array of Hashes with type and class_attributes keys. The key param is restricted to `IfThenRequiredDetails` or `OneOfRequiredDetails` and the class_attributes param is dependant on the type param. So if type param is `IfThenRequiredDetails` then class_attributes is restricted to valid `SchemaSerializer::IfThenRequiredDetails` params.
- *NOTE*: If you are constructing and using SchemaSerializer classes as standalone and not attached to a ValidationSchema or SchemaPropertyField, then you need to use string hash keys in the Hashes. This is due to serialization that doesn't occur when accessing outside of ValidationSchema or SchemaPropertyField models. This goes for all SchemaSerializer classes. If testing/using not associatied to parent field_details model then use string hash keys and not symbols.

```
AllOfDetailsPropsType = {
  properties: {
    type: "IfThenRequiredDetails" | "OneOfRequiredDetails",
    class_attributes: IfThenRequiredDetailsProps | OneOfRequiredDetailsProps
  }[]
}

details = SchemaSerializer::AllOfDetails.new(
  properties: [
    {
      "type" => "IfThenRequiredDetails",
      "class_attributes" => {
        "property_name"   => "propertyA",
        "property_const"  => true,
        "then_required"   => ["propertyB"],
        "else_required"   => ["propertyC"]
      },
    },
    {
      "type" => "OneOfRequiredDetails",
      "class_attributes" => {
        "required_properties" => [["propertyD"], ["propertyE", "propertyF"]]
      },
    }
  ]
)

details.to_schema_property
>>>>
[
  {
    "if"   => { "properties" => { "propertyA" => { "const" => true } } },
    "then" => { "required"   => ["propertyB"] },
    "else" => { "required"   => ["propertyC"] }
  },
  {
    "oneOf" => [
      {
        "required" => ["propertyD"]
      },
      {
        "required" => ["propertyE", "propertyF"]
      }
    ]
  }
]
```
### SchemaSerializer::IfThenRequiredDetails
- Used to construct complex if/then/else required field logic.
- This is used to require different fields based on the outcome of other fields.
- The `property_name` is the name of the schema_property_field you want to depend on and check against.
- The `property_const` can be restricted to a TrueClass, FalseClass or String property. This is the value of the schema_property_field named in property_name, to check against. This allows us to construct schemas where one form can be required versus another depending on users input to a boolean or string field, such as a country input i.e. "US" or "CA".
- The `then_required` property is an Array of Strings. The strings should be names of schema_property_fields that you want to be required if the entry of property_const results in True.
- The `else_required` property is optional and is an Array of Strings. The strings should be names of schema_property_fields that you want to be required if the entry of property_const results in False.
```
IfThenRequiredDetailsPropsType = {
  property_name: string
  property_const: string or boolean
  then_required: string[]
  else_required?: string[]
}

details = SchemaSerializer::IfThenRequiredDetails.new(
  property_name: "propertyA",
  property_const: true,
  then_required: ["propertyB"],
  else_required: ["propertyC"]
)

details.to_schema_property
>>>>
{
  "if"   => { "properties" => { "propertyA" => { "const" => true } } },
  "then" => { "required"   => ["propertyB"] },
  "else" => { "required"   => ["propertyC"] }
}
```
In this above scenario `propertyA` is a Boolean property field i.e. SchemaPropertyFieldBoolean.new(name: "propertyA")
### SchemaSerializer::OneOfRequiredDetails
- The `required_properties` param is required Array of Array Strings.
```
OneOfRequiredDetailsPropsType = {
  required_properties: string[][]
}

details = SchemaSerializer::OneOfRequiredDetails.new(required_properties: [["propertyD"], ["propertyE", "propertyF"]])

details.to_schema_property
>>>>
{
  "oneOf" => [
    {
      "required" => ["propertyD"]
    },
    {
      "required" => ["propertyE", "propertyF"]
    }
  ]
}
```

## SchemaPropertyField
- SchemaPropertyField has been established as a single table inheritance with the following models as types: `SchemaPropertyFieldArray, SchemaPropertyFieldBoolean, SchemaPropertyFieldNumber, SchemaPropertyFieldObject, SchemaPropertyFieldString`.
- The `name` attribute is used to set the property key when building the schema for the ValidationSchema model.
- The `title` and `description` attributes can be used to add labels and more information to property the fields.
- The `field_details` attribute has been setup as a jsonb column and each model has it's own serializer for validating and loading specific type data.

### SchemaPropertyFieldArray
- Used for properties requiring multiple entries i.e. aliases, address history, education history and employment history.
```
details = SchemaPropertyFieldArray.new(name: "aliases", title: "Known Aliases", field_details: SchemaSerializer::ArrayDetails.new(min_items: 1, max_items: 5, 
  item: {
    "type" => "SchemaPropertyFieldString",
    "class_attributes" => { "name" => "alias"},
    "field_details" => { "min_length" => 1 }
  }
))

details.to_schema_property
>>>>
{
  "title"     => "Known Aliases",
  "type"      => "array",
  "minItems"  => 1,
  "maxItems"  => 5,
  "items" => {
    "minLength" => 1,
    "type"      => "string"
  }
}
```
#### SchemaSerializer::ArrayDetails
- Used to add Array type specific properties to the schema_property_field_array class
- `minItems` describes the minimum number of entries needed for property to be valid.
- `maxItems` describes the maximum number of entries allowed for property to be valid.
- `uniqueItems` describes the whether or not the entries need to be different or can be alike for property to be valid.
- `item` describes the type of items that should be in the array response i.e. strings, numbers, objects.

```
SchemaSerializer::ArrayDetailsPropsType = {
  minItems?: number,
  maxItems?: number,
  uniqueItems?: boolean
  item: {
    type: inclusion in SchemaPropertyField types
    class_attributes: validated against SchemaPropertyField model minus validation_schema relationship
    field_details?: validated against SchemaPropertyField type field_details serializer
  }
}

details = SchemaPropertyFieldArray.new(name: "addresses", title: "Address History", field_details: SchemaSerializer::ArrayDetails.new(min_items: 1, max_items: 2, unique_items: true, item: {
        type: "SchemaPropertyFieldObject",
        class_attributes: { name: "address", description: "Adress", title: "Enter Address" },
        field_details: {
          properties: [
            {
              type: "SchemaPropertyFieldString",
              class_attributes: { name: "street", description: "Name of street", title: "Street Name", required: true },
              field_details: { min_length: 1 }
            },
            {
              type: "SchemaPropertyFieldString",
              class_attributes: { name: "city", description: "Name of city", title: "City Name", required: true },
              field_details: { min_length: 1 }
            }
          ]
        }
      }))

details.to_schema_property
>>>>
{
  "title"       => "Address History",
  "type"        => "array",
  "minItems"    => 1,
  "maxItems"    => 2,
  "uniqueItems" => true,
  "items"       => {
    "description" => "Enter your address",
    "title"       => "Address",
    "type"        => "object",
    "properties"  => {
      "street" => {
        "description" => "Name of street",
        "minLength"   => 1,
        "title"       => "Street Name",
        "type"        => "string"
      },
      "city" => {
        "description" => "Name of city",
        "minLength"   => 1,
        "title"       => "City Name",
        "type"        => "string"
      },
    },
    "required" => ["street", "city"],
  }
}
```

### SchemaPropertyFieldBoolean
- Used for properties requiring a boolean (true/false) response value.
```
details = SchemaPropertyFieldBoolean.new(name: "subscribe", title: "Subscribe", description: "Do you wish to subscribe to our newsletter?")

details.to_schema_property
>>>>
{
  "title"       => "Subscribe",
  "description" => "Do you wish to subscribe to our newsletter?",
  "type"        => "boolean",
}
```
#### SchemaSerializer::BooleanDetails
- Used to add Boolean type specific properties to the schema_property_field_boolean class
- `const` restricted to `true` or `false` is used to restrict a valid response to a specific answer.

```
SchemaSerializer::BooleanDetailsPropsType = {
  const: true | false,
}

details = SchemaPropertyFieldBoolean.new(name: "consentForm", title: "Consent Form", description: "Do you consent to your data being used?", field_details: SchemaSerializer::BooleanDetails.new(const: true))

details.to_schema_property
>>>>
{
  "title"       => "Consent Form"",
  "description" => "Do you consent to your data being used?"
  "type"        => "boolean",
  "const"       => true,
}
```
- In this above example, only a value of `{ consentForm: true }` would be considered valid.

### SchemaPropertyFieldNumber
- Used for properties requiring a number (integer) response value.
```
details = SchemaPropertyFieldNumber.new(name: "age", title: "Current Age", description: "Please enter your age")

details.to_schema_property
>>>>
{
  "title"       => "Current Age",
  "description" => "Please enter your age",
  "type"        => "number",
}
```
#### SchemaSerializer::NumberDetails
- Used to add Number type specific properties to the schema_property_field_number class
- `min_value` the minimum value for a valid response.
- `max_value` the maximum value for a valid response.

```
SchemaSerializer::NumberDetailsPropsType = {
  min_value?: number,
  max_value?: number,
}

details = SchemaPropertyFieldNumber.new(name: "age", title: "Current Age", description: "Please enter your age", field_details: SchemaSerializer::NumberDetails.new(min_value: 21))

details.to_schema_property
>>>>
{
  "title"       => "Current Age",
  "description" => "Please enter your age",
  "type"        => "number",
  "minValue"    => 21
}
```
- In this above example, only a value > 21 would be valid i.e. `{ age: 21 }`

### SchemaPropertyFieldObject
- Used to add Object type specific properties to the schema_property_field_object class.
- The `object` property is essentially a validation schema within a validation schema. It is made up of a collection of other properties.
- The `field_details` attribute is required for SchemaPropertyFieldObject to be valid. You need those properties added in order to build the schema property block for an `object` type.

#### SchemaSerializer::ObjectDetails
- Used to build the child properties associated to the parent schema property.
```
SchemaSerializer::ObjectDetailsPropsType  {
  type: inclusion in SchemaPropertyField types
  class_attributes: validated against SchemaPropertyField model minus validation_schema relationship
  field_details?: validated against SchemaPropertyField type field_details serializer
  all_of?: {
    type: "IfThenRequiredDetails" | "OneOfRequiredDetails",
    class_attributes: IfThenRequiredDetailsProps | OneOfRequiredDetailsProps
  }[]
}

details = SchemaPropertyFieldObject.new(
  name: "address",
  title: "Address",
  description: "Enter your address",
  field_details: SchemaSerializer::ObjectDetails.new(properties: [
    {
      type: "SchemaPropertyFieldString",
      class_attributes: { name: "street", required: true },
    },
    {
      type: "SchemaPropertyFieldString",
      class_attributes: { name: "city", required: true },
    },
    {
      type: "SchemaPropertyFieldString",
      class_attributes: { name: "state", required: true },
    },
  ])
)

details.to_schema_property
>>>>
{
  "title"       => "Address",
  "description" => "Enter your address",
  "type"        => "object",
  "properties"  => {
    "street" => { "type" => "string" },
    "city"   => { "type" => "string" },
    "state"  => { "type" => "string" },
  },
  "required" => ["street", "city", "state"]
}
```
- The `object` type `field_details` can also accept the `all_of` param same as the ValidationSchema.
```
details = SchemaPropertyFieldObject.new(
  name: "identification",
  title: "Identification",
  description: "Please provide valid identifying number",
  field_details: SchemaSerializer::ObjectDetails.new(
    properties: [
      {
        type: "SchemaPropertyFieldString",
        class_attributes: { name: "ssn" },
      },
      {
        type: "SchemaPropertyFieldString",
        class_attributes: { name: "passportNumber" },
      },
      {
        type: "SchemaPropertyFieldObject",
        class_attributes: { name: "driversLicense" },
      },
    ],
    all_of: [
      {
        "type" => "IfThenRequiredDetails",
        "class_attributes" => {
          "property_name"   => "birthPlace",
          "property_const"  => "US",
          "then_required"   => ["ssn"],
          "else_required"   => ["passportNumber", "driversLicense"]
        },
      },
    ]
  )
)

details.to_schema_property
>>>>
{
  "title"       => "Identification",
  "description" => "Please provide valid identifying number",
  "type"        => "object",
  "properties"  => {
    "ssn"             => { "type" => "string" },
    "passportNumber"  => { "type" => "string" },
    "driversLicense"  => { "type" => "string" },
  },
  "allOf" => [
    {
      "if"   => { "properties" => { "birthPlace" => { "const" => "US" } } },
      "then" => { "required"   => ["ssn"] },
      "else" => { "required"   => ["passportNumber", "driversLicense"] }
    }
  ]
}
```

### SchemaPropertyFieldString
- Used for properties requiring a `string` response value.
```
details = SchemaPropertyFieldString.new(name: "firstName", title: "First Name", description: "Please enter your first name")

details.to_schema_property
>>>>
{
  "title"       => "First Name",
  "description" => "Please enter your first name",
  "type"        => "string",
}
```

#### SchemaSerializer::StringDetails
- Used to add String type specific properties to the schema_property_field_string class
- `const` restricts valid responses to value in this field.
- `pattern` a string regex pattern to validate the response against.
- `enum` restricts valid response to one of strings in this array.
- `format` restricts valid reponse to format type.
- `min_length` the minimum length for a valid response.
- `max_length` the maximum length for a valid response.

```
SchemaSerializer::StringDetailsPropsType = {
  const?: string,
  pattern?: string,
  enum?: string[],
  format?: "date" | "date-time" | "email" | "uri"
  min_length?: number,
  max_length?: number,
}

details = SchemaPropertyFieldString.new(name: "zipcode", title: "Zipcode", description: "Please enter your zipcode", field_details: SchemaSerializer::StringDetails.new(pattern: "(^\d{5}$)|(^\d{5}-\d{4}$)"))

details.to_schema_property
>>>>
{
  "title"       => "Zipcode",
  "description" => "Please enter your zipcode",
  "type"        => "string",
  "pattern"     => "(^\d{5}$)|(^\d{5}-\d{4}$)"
}
```
In this above example you would have to provide a US zipcode for this field to be valid i.e. 5 digits or 5 digits dash 4 digits.
