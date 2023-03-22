import type { SidebarConfig } from '@vuepress/theme-default'

export const sidebarZh: SidebarConfig = {
  '/guide/': [
    {
      text: 'Crimson-SDK',
      children: [
        '/guide/overview.md',
        '/guide/faq.md',
        '/guide/android.md',
        '/guide/ios.md',
        '/guide/flutter.md',
        '/guide/c.md',
        '/guide/csharp.md',
        '/guide/python.md',
        '/guide/node.md',
        '/guide/node_electron.md',
      ],
    },
  ],
}
