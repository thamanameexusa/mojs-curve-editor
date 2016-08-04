require('./resize-handle');
require('./icons');
require('./icon');
require('./icon-button');
require('./icon-divider');
require('./curve');

<curve-editor class={this.CLASSES['curve-editor']} style={this.getStyle()}>
  <icons />

  <div class={this.CLASSES['curve-editor__left']}>
    <icon-button shape="code"></icon-button>
    <icon-divider shape="divider"></icon-divider>
    <a href="https://github.com/legomushroom/mojs-curve-editor" target="_blank" class={this.CLASSES['curve-editor__mojs-logo']}>
      <icon shape="mojs-logo" />
    </a>
  </div>

  <div class={this.CLASSES['curve-editor__right']}>
    <curve />
    <resize-handle type="top"></resize-handle>
    <resize-handle type="right"></resize-handle>
    <resize-handle type="bottom"></resize-handle>
  </div>
  
  <script type="babel">
    require('../../css/blocks/curve-editor');
    this.CLASSES = require('../../css/blocks/curve-editor.postcss.css.json');

    import Hammer from 'hammerjs';
    import propagating from 'propagating-hammerjs';
    import mod from '../helpers/resize-mod';

    const {store} = opts;
    store.subscribe(this.update.bind(this));

    this.on('mount', () => {
      var hammertime = propagating(new Hammer(this.root))
        .on('pan', (ev) => {
          this.x = ev.deltaX;
          this.y = ev.deltaY;
          this.update();
        })
        .on('panend', (ev) => {
          const x = ev.deltaX,
                y = ev.deltaY,
                {translate} = store.getState().present.resize;

          this.x = this.y = 0;
          store.dispatch({ type: 'EDITOR_TRANSLATE', data: { x: translate.x + x, y: translate.y + y } })
        });
    });

    this.getStyle = () => {
      const state = store.getState().present.resize;
      let {temp_top} = state;
      let {temp_bottom} = state;
      let {temp_right} = state;

      temp_top += state.top;
      temp_bottom += state.bottom;
      temp_right += state.right;

      const X_SIZE = 411;
      const Y_SIZE = 378;

      // constrain min height
      if (Y_SIZE - temp_top < Y_SIZE) { temp_top = 0; }
      if (Y_SIZE + temp_bottom < Y_SIZE) { temp_bottom = 0; }
      if (X_SIZE + temp_right < X_SIZE) { temp_right = 0; }
      
      temp_top    = mod( temp_top, -1 );
      temp_bottom = mod( temp_bottom );

      const {translate} = state,
            height = `height: ${Y_SIZE - temp_top + temp_bottom}px`,
            width  = `width: ${X_SIZE + temp_right}px`,
            x = (this.x || 0) + translate.x,
            y = (this.y || 0) + translate.y,
            transform = `transform: translate(${x}px, ${y + temp_top}px)`;

      return `${mojs.h.prefix.css}${transform}; ${transform}; ${width}; ${height};`;
    }


  </script>

</curve-editor>