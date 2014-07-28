# CalCentral JavaScript Styleguide

* **Indentation**: 2 spaces
* List items/properties **alphabetically**
* Use an editor that supports **[.editorconfig](http://editorconfig.org/#overview)**. Feel free to have a look at the [editor plug-ins](http://editorconfig.org/#download)
* Remove `console.log()` messages when committing your code.
* Only use anchor tags `<a>` for actual links, otherwise use `<button>` instead. _This is especially important for IE9_.
* Never use ngBindHtmlUnsafe.
* Never use innerHTML unless displaying completely static data.
* Filenames for images should be in the following format: `name_name2_00x00.ext`. When it's an icon (e.g. 32x32 / 64x64), then start it with `icon_`.
* Specify **colors** in `hex` format and create a variable for them.
* Write `0` instead of `0px`.
* Use `data-ng-if` instead of `data-ng-show` or `data-ng-hide` when possible.
* Optimize images:
  * [imageOptim](http://imageoptim.com/) for binary images (gif / png / jpg)
  * [svgo](https://github.com/svg/svgo/) for vector images (svg)
* Use multiple lines for `var` statements and specify `var` on each line:

    :-1:
    ```javascript
    var name = 'Jason',
      name2 = 'Mike'
    ```

    :+1:
    ```javascript
    var name = 'Jason';
    var name2 = 'Mike';
    ```

* Write objects on multiple lines:

    :-1:
    ```javascript
    var enabled = { faceplant: true };
    ```

    :+1:
    ```javascript
    var enabled = {
      faceplant: true
    };
    ```

* Use **single quotes** when possible

    :-1:
    ```javascript
    var name = "Christian Vuerings";
    ```

    :+1:
    ```javascript
    var name = 'Christian Vuerings';
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
