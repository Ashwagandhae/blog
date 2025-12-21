<script>
  import Email from "$lib/components/Email.svelte";
  import { titleSuffix } from "$lib/title";
</script>

<svelte:head>
  <title>About{titleSuffix}</title>
</svelte:head>
<h1>About</h1>
<p>
  Hello, I'm Julian. I'm studying Computer Science at the Georgia Institute of
  Technology.
</p>
<h2>Contact</h2>
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
  <li>Email: <Email user="julianlianbauer" domain="gmail.com" /></li>
  <li>Discord: ashwagandhae</li>
</ul>
