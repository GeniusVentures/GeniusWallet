# Hive

Run the following command to generate the hive models
<code>
flutter packages pub run build_runner build
</code>


!Important
Each model needs a unique typeId

For example
@HiveType(typeId: 1)
@HiveType(typeId: 2)
@HiveType(typeId: 3)

... new models will have 4, 5... etc