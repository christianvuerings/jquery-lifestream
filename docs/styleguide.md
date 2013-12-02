# CalCentral Styleguide

* **Indentation**: 2 spaces
* List items/properties **alphabetically**
* Use an editor that supports **[.editorconfig](http://editorconfig.org/#overview)**. Feel free to have a look at the [editor plug-ins](http://editorconfig.org/#download)
* Remove `console.log()` messages when committing your code.
* Only use anchor tags `<a>` for actual links, otherwise use `<button>` instead. _This is especially important for IE9_.
* Never use ngBindHtmlUnsafe.
* Never use innerHTML unless displaying completely static data.
* Filenames for images should be in the following format: `name_name2_00x00.ext`. When it's an icon (e.g. 32x32 / 64x64), then start it with `icon_`.
* Use **single quotes** when possible

:-1:
```javascript
var name="Christian Vuerings";
```
:+1:
```javascript
var name='Christian Vuerings';
```

* Use `data-ng-` instead of `ng-` or `ng:` and add `data-` for directives

:-1:
```html
<ng:view>
<span ng-bind="name"></span>
<input mmddyyvalidator />
```
:+1:
```html
<div data-ng-view></div>
<span data-ng-bind="name"></span>
<input data-mmddyyvalidator />
```
