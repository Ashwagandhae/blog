<script>
  import ContactForm from "$lib/components/ContactForm.svelte";
  import { titleSuffix } from "$lib/title";
</script>

<svelte:head>
  <title>Contact{titleSuffix}</title>
  <meta
    name="description"
    content="Contact form to send messages by pigeon to Julian Bauer."
  />
</svelte:head>

<h1>Contact</h1>
<ContactForm />
