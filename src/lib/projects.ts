export type Project = {
  name: string;
  links: Record<string, string>;
  description: string;
  image?: { src: string; alt: string };
  tags: string[];
};
export const projects: Project[] = [
  {
    name: "Flower",
    links: {
      github: "https://github.com/Ashwagandhae/debate-flow",
      web: "https://debate-flow.vercel.app/",
    },
    tags: ["typescript", "svelte"],
    description: `<p>
        Competitive debate note-taking app with automatic argument spacing,
        export to Excel, built-in timer, and live sharing.
      </p>`,
    image: {
      src: "flower.png",
      alt: "Screenshot of Flower app showing tree of debate arguments and timer",
    },
  },

  {
    name: "Mutable",
    links: {
      github: "https://github.com/Ashwagandhae/mutable",
    },
    tags: ["rust", "parallel"],
    description: `<p>
        Evolution simulator able to spontaneously evolve plants detritivores and
        herbivores, with parallel physics engine and implementation of
        <a
          href="https://en.wikipedia.org/wiki/Neuroevolution_of_augmenting_topologies"
          >NEAT</a
        >.
      </p>`,
    image: {
      src: "mutable.gif",
      alt: "Recording of mutable showing sea of moving organisms",
    },
  },

  {
    name: "Rolly",
    links: {
      github: "https://github.com/Ashwagandhae/rolly",
      web: "https://ashwagandhae.github.io/rolly/",
    },
    tags: ["rust", "game", "wasm"],
    description: `<p>
        Platformer game where you roll into a ball to protect yourself from
        water.
      </p>`,
    image: {
      src: "rolly.gif",
      alt: "Gif of game Rolly being played, with the rolly character jumping accross grass hills, rocks, and water",
    },
  },

  {
    name: "Ur solution",
    links: {
      github: "https://github.com/Ashwagandhae/ur-solution",
    },
    tags: ["rust", "game", "parallel"],
    description: `<p>
        Solution to the <a href="https://en.wikipedia.org/wiki/Royal_Game_of_Ur"
          >Royal Game of Ur</a
        > Finkel Rules, with optimal moves calculated for every possible board state.
      </p>`,
  },
  {
    name: "Monochrome layers",
    links: {
      github: "https://github.com/Ashwagandhae/monochrome-layers",
    },
    tags: ["rust", "parallel"],
    description: `<p>
        Command line tool that uses an evolutionary algorithm to create layers
        of single-color pixel grids that approximate an image.
      </p>`,
    image: {
      src: "monochromeLayers.gif",
      alt: "Gif of monochrome layers being applied one-by-one to create image of two chickens",
    },
  },

  {
    name: "Idris sorted list",
    links: {
      github: "https://github.com/Ashwagandhae/cs-2051-dependent-types",
      writing: "/writing/idris-sorting",
    },
    tags: ["idris", "dependent-type"],
    description: `<p>
        Formal verification of insertion sort using the dependently-typed
        language <a href="https://idris-lang.org/">Idris</a>.
      </p>`,
  },

  {
    name: "Evidencer",
    links: {
      github: ", 'wasmhttps://github.com/Ashwagandhae/evidencer",
      release: "https://github.com/Ashwagandhae/evidencer/releases/",
    },
    tags: ["typescript", "svelte", "chrome-extension"],
    description: `<p>
        Auto-citation chrome extension for competitive debate with built-in
        formatting features.
      </p>`,
    image: {
      src: "evidencer.jpg",
      alt: "Screenshot of evidencer being used on Onion writing",
    },
  },

  {
    name: "Docx reader",
    links: {
      github: "https://github.com/Ashwagandhae/docx-reader",
    },
    tags: ["rust", "tauri", "typescript", "svelte"],
    description: `<p>
        Microsoft Word document reader for competitive debate that opens large
        documents 28 times faster than native app, with features like colorable
        windows and contextual search.
      </p>`,
  },
  {
    name: "Disarium",
    links: {
      github: "https://github.com/Ashwagandhae/disarium",
      writing: "/writing/disarium",
    },
    tags: ["rust", "parallel", "benchmark"],
    description: `<p>
        Rust program that finds all <a
          href="https://rosettacode.org/wiki/Disarium_numbers"
          >disarium numbers</a
        > in 12 seconds.
      </p>`,
  },
  {
    name: "Date-o fun remover",
    links: {
      github: "https://github.com/Ashwagandhae/dateo-fun-remover",
      web: "https://ashwagandhae.github.io/dateo-fun-remover/",
    },
    tags: ["rust", "game", "parallel", "wasm"],
    description: `<p>
        Solver for the math puzzle game <a href="https://dateo-math-game.com/"
          >Date-o</a
        >.
      </p>`,
    image: {
      src: "dateoFunRemover.png",
      alt: "Screenshot of date-o displaying solutions for the date 6/21/2026",
    },
  },

  {
    name: "Brot",
    links: {
      github: "https://github.com/Ashwagandhae/brot",
    },
    tags: ["rust", "tauri", "mobile", "typescript", "svelte", "typst"],
    description: `<p>
        Desktop & mobile note-taking app made for personal use, with support for
        global fuzzy search, Typst equations, and runnable code blocks.
      </p>`,

    image: {
      src: "brot.png",
      alt: "Screenshot of brot app displaying richly formatted text and a command palette",
    },
  },

  {
    name: "Gimkit block converter",
    links: {
      github: "https://github.com/Ashwagandhae/gimkit-block-converter",
    },
    tags: ["typescript"],
    description: `<p>
        <a href="https://github.com/Gimloader/Gimloader">Gimloader</a> plugin for
        the educational game Gimkit that converts JavaScript to Gimkit code blocks.
      </p>`,
    image: {
      src: "gimkitBlockConverter.jpg",
      alt: "Screenshot of Gimkit block converter converting javascript to equivalent Gimkit blocks",
    },
  },

  {
    name: "Advent of code",
    links: {
      github: "https://github.com/Ashwagandhae/advent-of-code",
    },
    tags: ["rust", "typescript", "python"],
    description: `<p>
        <a href="https://github.com/Gimloader/Gimloader">Advent of code </a> solutions,
        and a custom advent of code command line tool with auto submitting and support
        for multiple languages.
      </p>`,
  },

  {
    name: "Framework speak",
    links: {
      github: "https://github.com/Ashwagandhae/framework-speak",
      web: "https://ashwagandhae.github.io/framework-speak/",
    },
    tags: ["rust", "typescript", "wasm"],
    description: `<p>
        Tool that automatically replaces english words with phonetically similar
        JavaScript frameworks.
      </p>`,
    image: {
      src: "frameworkSpeak.png",
      alt: "Screenshot of framework speak with the text 'Change your point of view' on the left and 'Change your point of Vue' on the right.",
    },
  },

  {
    name: "Typesweeper",
    links: {
      github: "https://github.com/Ashwagandhae/typesweeper",
    },
    tags: ["typst", "game"],
    description: `<p>
        Implementation of minesweeper in pure Typst, using the live preview
        editing as controls for the game.
      </p>`,
    image: {
      src: "typesweeper.png",
      alt: "Screenshot of typst source code being edited on the left to control minesweeper game on the right",
    },
  },

  {
    name: "Ethical CS 1331",
    links: {
      github: "https://github.com/Ashwagandhae/ethical-cs-1331",
    },
    tags: ["haskell", "idris"],
    description: `<p>
        All my Georgia Tech CS 1331 homeworks and programming exercises
        rewritten in the functional language Haskell and functional
        depedently-typed language Idris.
      </p>`,
  },

  {
    name: "Clairo charm notebook",
    links: {
      github: "https://github.com/Ashwagandhae/clairo-charm-notebook",
    },
    tags: ["typst"],
    description: `<p>
        A <a href="https://chaucer.fas.harvard.edu/types-editions"
          >diplomatic edition</a
        >
        of <a href="https://en.wikipedia.org/wiki/Clairo">Clairo's</a>
        <a href="https://en.wikipedia.org/wiki/Charm_(Clairo_album)">Charm</a>
        notebook that was shown in
        <a href="https://www.tiktok.com/@xxclairoxx/video/7573392753493626126">this tiktok</a
        >.
      </p>`,
    image: {
      src: "clairoCharmNotebook.png",
      alt: "Screenshot of Typst source next to the front page of the diplomatic edition of Clairo's charm notebook.",
    },
  },
];
