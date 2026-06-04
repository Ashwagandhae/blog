
export async function load({ params }) {
  const tag = params.slug;

  return {
    tag,
  };
}
