# crud-muffins

<img src="https://i.imgur.com/MPbwMBs.jpg" width="100">

A half-baked solution to UI CRUD operations.

## Motivation

Because I got super tired of writing the basic state management of CRUD operations in my webapps, including:

1. Loading the collection (Reading)
1. Creating a new item
1. Updating an item
1. Deleting an item
1. ...and all the UI state associated with it (e.g. `isEditing`, `isSaving`, etc.)

## Usage

The API will likely change quite a lot over the next several iterations. It's designed to work with any UI library, e.g. React, you just need to pass in the controls for reading/setting state.

Here's an example usage in React:

```javascript
// some special function to process/extract data from the server payload
const unbox = response => ({
  data: compose(map(prop('data')), prop('data'), prop('data'))(response),
  pagination: response.data.pagination,
})

const {
  create, load, update, destroy, items,
  ui: { isSaving, isEditing, startEditing, stopEditing, isSavingNew },
} = useCrudMuffins(axios, '/todos', ...useState([]), ...useState({}), { loadPostProcessor: unbox })

/**
 * From there you can do things like:
 * 
 *   - await load(params)
 *   - await update(id, params)
 *   - await create(params)
 *   - isSaving(id)
 *   - isEditing(id)
 *   - startEditing(id)
 *   - stopEditing(id)
 * 
 * etc...
 */
```

Working demo example to come.

## Credits

Image credit: @zspencer

Code collaborator: @zspencer 
