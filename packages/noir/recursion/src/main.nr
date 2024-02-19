use dep::std;

fn main(
    verification_key : [Field; 114], 
    proof_first : [Field; 93], 
    public_inputs_first : [Field; 1],
    proof_second: [Field; 93],
    public_inputs_second: [Field; 1], 
    key_hash : Field,
) {
    std::verify_proof(
        verification_key.as_slice(), 
        proof_first.as_slice(), 
        public_inputs_first.as_slice(), 
        key_hash,
    );

    std::verify_proof(
        verification_key.as_slice(), 
        proof_second.as_slice(), 
        public_inputs_second.as_slice(), 
        key_hash,
    );
}
