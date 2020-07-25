import { assocPath, concat, curry, path, update as rUpdate } from 'ramda'
import { findIndexById, removeById } from './helpers'

export const useCrudMuffinsUI = (ui, setUi) => {
  const isSaving = (id) => path([id, 'saving'], ui)
  const setSaving = (value, id) => setUi(assocPath([id, 'saving'], value, ui))
  const isEditing = (id) => path([id, 'editing'], ui)
  const setEditing = curry((value, id) => setUi(assocPath([id, 'editing'], value, ui)))
  const startEditing = setEditing(true)
  const stopEditing = setEditing(false)
  const isSavingNew = () => isSaving('_new')
  const setSavingNew = (value) => setSaving(value, '_new')

  const update = async (id, cb) => {
    // TODO add try/catch
    setSaving(true, id)

    const item = await cb()

    setSaving(false, id)
    setEditing(false, id)
    return item
  }

  const create = async (cb) => {
    // TODO add try/catch
    setSavingNew(true)
    const item = await cb()
    setSavingNew(false)
    return item
  }

  const destroy = async (id, cb) => {
    // TODO add try/catch
    setSaving(true, id)

    await cb()

    setSaving(false, id)
    setEditing(false, id)
  }

  return {
    isSaving, setSaving, isEditing, startEditing, stopEditing, isSavingNew, setSavingNew, update, create, destroy,
  }
}

export const useCrudMuffins = (api, route, items, setItems, ui, setUi) => {
  // we need both right now because sometimes we change the order of the arguments
  const updateItem = item => rUpdate(findIndexById(item.id, items), item, items)
  const removeItem = id => removeById(id, items)

  const cmUI = useCrudMuffinsUI(ui, setUi)

  const load = async (params) => {
    const res = await api.get(route, { params })
    const { data } = res
    setItems(concat(items, data))
    return res
  }

  const create = async (params, config) => {
    const { data: { data: item } } = await cmUI.create(() => api.post(route, params, config))
    setItems(concat([item], items))
    return item
  }

  const update = async (id, params, config) => {
    const { data: { data: item } } = await cmUI.update(
      id,
      () => api.put(`${route}/${id}`, params, config),
    )
    setItems(updateItem(item))
  }

  const destroy = async (id) => {
    await cmUI.destroy(id, () => api.delete(`${route}/${id}`))
    setItems(removeItem(id))
  }

  return { load, create, update, destroy, ui: cmUI, items }
}
