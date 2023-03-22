import type { SidebarConfig } from '@vuepress/theme-default'

export const sidebarEn: SidebarConfig = {
  '/en/guide/': [
    {
      text: 'Crimson-SDK',
      children: [
        '/en/guide/overview.md',
        '/en/guide/faq.md',
        '/en/guide/android.md',
        '/en/guide/ios.md',
        '/en/guide/flutter.md',
        '/en/guide/c.md',
        '/en/guide/csharp.md',
        '/en/guide/python.md',
        '/en/guide/node.md',
        '/en/guide/node_electron.md',
        '/en/guide/chrome_extension.md',
      ],
    },
  ],
}
