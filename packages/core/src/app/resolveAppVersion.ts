import { fs } from '@vuepress/utils'
import { createRequire } from 'node:module'

const require = createRequire(import.meta.url)

/**
 * Resolve version of vuepress app
 */
export const resolveAppVersion = (): string => {
  const pkgJson = fs.readJsonSync(
    require.resolve('@vuepress/core/package.json')
  )
  return pkgJson.version
}
