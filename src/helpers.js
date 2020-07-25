import { curry, reject, findIndex, propEq } from 'ramda'

export const removeById = curry((id, xs) => reject(propEq('id', id), xs))
export const findIndexById = (id, xs) => findIndex(propEq('id', id), xs)
