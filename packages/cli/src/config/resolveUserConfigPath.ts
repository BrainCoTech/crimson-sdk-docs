import { colors, fs, logger, path } from '@vuepress/utils'
import process from 'node:process'

/**
 * Resolve file path of user config
 */
export const resolveUserConfigPath = (
  config: string,
  cwd = process.cwd()
): string => {
  const configPath = path.resolve(cwd, config)

  if (!fs.pathExistsSync(configPath)) {
    throw logger.createError(
      `config file does not exist: ${colors.magenta(config)}`
    )
  }

  return configPath
}
