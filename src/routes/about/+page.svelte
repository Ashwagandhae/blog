<script>
  import ContactForm from "$lib/components/ContactForm.svelte";
  import { titleSuffix } from "$lib/title";
</script>

<svelte:head>
  <title>About{titleSuffix}</title>
</svelte:head>
<h1>About</h1>
<p>
  Hi, I'm Julian. I'm studying Computer Science at the Georgia Institute of
  Technology, threading in <a
    href="https://www.cc.gatech.edu/academics/threads/systems-architecture"
    >Systems & Architecture</a
  >
  and <a href="https://www.cc.gatech.edu/academics/threads/devices">Devices</a>.
</p>
<p>
  I'm interested in programming languages, embedded systems, and UI design. I
  also like playing piano and taking care of chickens.
</p>
<h2>Connect</h2>
<ul>
  <li>
    GitHub: <a href="https://github.com/Ashwagandhae">github.com/Ashwagandhae</a
    >
  </li>
  <li>
    LinkedIn: <a href="https://www.linkedin.com/in/julian-bauer-32823b246/"
      >linkedin.com/in/julian-bauer-32823b246</a
    >
  </li>
  <li>Discord: ashwagandhae</li>
</ul>
<h2>Contact</h2>
<ContactForm />
<h2>Website source</h2>
<p>
  Written with
  <a href="https://svelte.dev/docs/kit/introduction">SvelteKit</a>, using
  <a href="https://typst.app/">Typst</a>
  as the markup language for
  <a href="/writing">writing</a>. You can find
  <a href="https://github.com/Ashwagandhae/blog">the source code on GitHub</a>.
</p>
