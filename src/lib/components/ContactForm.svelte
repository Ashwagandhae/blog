<script lang="ts">
  let status:
    | { type: "waiting" }
    | { type: "submitting" }
    | { type: "success" }
    | { type: "error"; message: string | null } = $state({ type: "waiting" });
  const handleSubmit = async (event: any) => {
    event.preventDefault();
    status = { type: "submitting" };
    const formData = new FormData(event.currentTarget);
    const object = Object.fromEntries(formData);
    const json = JSON.stringify(object);

    const response = await fetch("https://api.web3s.com/submit", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
      body: json,
    });
    const result = await response.json();
    if (result.success) {
      status = { type: "success" };
    } else {
      status = { type: "error", message: result.message || null };
    }
  };

  let submitButtonText: string = $derived.by(() => {
    switch (status.type) {
      case "waiting":
        return "submit";
      case "submitting":
        return "submitting...";
      case "success":
        return "success";
      case "error":
        return status.message ?? "something went wrong";
    }
  });

  const accessKey = "5504dc78-0cce-444d-9858-baf15d873833";
</script>

<form onsubmit={handleSubmit}>
  <input type="hidden" name="access_key" value={accessKey} />
  <input placeholder="name" type="text" name="name" required />
  <input placeholder="email" type="email" name="email" required />
  <textarea placeholder="message" name="message" required rows="4"></textarea>
  <button type="submit" disabled={status.type != "waiting"}
    >{submitButtonText}</button
  >
</form>

<style>
  form {
    display: grid;
    grid-template-areas:
      "name name"
      "email email"
      "message message"
      "submit submit";
    gap: var(--pad);
  }
  @media (min-width: 500px) {
    form {
      grid-template-areas:
        "name email"
        "message message"
        "submit submit";
    }
  }
  textarea {
    grid-area: message;
  }
  button {
    grid-area: submit;
  }
  input[name="name"] {
    grid-area: name;
  }
  input[name="email"] {
    grid-area: email;
  }

  textarea {
    resize: vertical;
    min-height: 80px;
  }

  button[type="submit"] {
    width: 100%;
    text-align: center;
  }
  input {
    width: 100%;
  }
</style>
